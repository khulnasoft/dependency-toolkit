using System.Net;
using System.Text.Json;
using System.Text.Json.Serialization;

using NuGetUpdater.Core.Analyze;
using NuGetUpdater.Core.Updater;

namespace NuGetUpdater.Core;

public class UpdaterWorker
{
    private readonly Logger _logger;
    private readonly HashSet<string> _processedProjectPaths = new(StringComparer.OrdinalIgnoreCase);

    internal static readonly JsonSerializerOptions SerializerOptions = new()
    {
        WriteIndented = true,
        Converters = { new JsonStringEnumConverter() },
    };

    public UpdaterWorker(Logger logger)
    {
        _logger = logger;
    }

    public async Task RunAsync(string repoRootPath, string workspacePath, string dependencyName, string previousDependencyVersion, string newDependencyVersion, bool isTransitive, string? resultOutputPath = null)
    {
        MSBuildHelper.RegisterMSBuild(Environment.CurrentDirectory, repoRootPath);
        UpdateOperationResult result;

        if (!Path.IsPathRooted(workspacePath) || !File.Exists(workspacePath))
        {
            workspacePath = Path.GetFullPath(Path.Join(repoRootPath, workspacePath));
        }

        try
        {
            if (!isTransitive)
            {
                await DotNetToolsJsonUpdater.UpdateDependencyAsync(repoRootPath, workspacePath, dependencyName, previousDependencyVersion, newDependencyVersion, _logger);
                await GlobalJsonUpdater.UpdateDependencyAsync(repoRootPath, workspacePath, dependencyName, previousDependencyVersion, newDependencyVersion, _logger);
            }

            var extension = Path.GetExtension(workspacePath).ToLowerInvariant();
            switch (extension)
            {
                case ".sln":
                    await RunForSolutionAsync(repoRootPath, workspacePath, dependencyName, previousDependencyVersion, newDependencyVersion, isTransitive);
                    break;
                case ".proj":
                    await RunForProjFileAsync(repoRootPath, workspacePath, dependencyName, previousDependencyVersion, newDependencyVersion, isTransitive);
                    break;
                case ".csproj":
                case ".fsproj":
                case ".vbproj":
                    await RunForProjectAsync(repoRootPath, workspacePath, dependencyName, previousDependencyVersion, newDependencyVersion, isTransitive);
                    break;
                default:
                    _logger.Log($"File extension [{extension}] is not supported.");
                    break;
            }

            result = new(); // all ok
            _logger.Log("Update complete.");
        }
        catch (HttpRequestException ex)
        when (ex.StatusCode == HttpStatusCode.Unauthorized || ex.StatusCode == HttpStatusCode.Forbidden)
        {
            // TODO: consolidate this error handling between AnalyzeWorker, DiscoveryWorker, and UpdateWorker
            result = new()
            {
                ErrorType = ErrorType.AuthenticationFailure,
                ErrorDetails = "(" + string.Join("|", NuGetContext.GetPackageSourceUrls(workspacePath)) + ")",
            };
        }
        catch (MissingFileException ex)
        {
            result = new()
            {
                ErrorType = ErrorType.MissingFile,
                ErrorDetails = ex.FilePath,
            };
        }

        _processedProjectPaths.Clear();
        if (resultOutputPath is { })
        {
            await WriteResultFile(result, resultOutputPath, _logger);
        }
    }

    internal static async Task WriteResultFile(UpdateOperationResult result, string resultOutputPath, Logger logger)
    {
        logger.Log($"  Writing update result to [{resultOutputPath}].");

        var resultJson = JsonSerializer.Serialize(result, SerializerOptions);
        await File.WriteAllTextAsync(resultOutputPath, resultJson);
    }

    private async Task RunForSolutionAsync(
        string repoRootPath,
        string solutionPath,
        string dependencyName,
        string previousDependencyVersion,
        string newDependencyVersion,
        bool isTransitive)
    {
        _logger.Log($"Running for solution [{Path.GetRelativePath(repoRootPath, solutionPath)}]");
        var projectPaths = MSBuildHelper.GetProjectPathsFromSolution(solutionPath);
        foreach (var projectPath in projectPaths)
        {
            await RunForProjectAsync(repoRootPath, projectPath, dependencyName, previousDependencyVersion, newDependencyVersion, isTransitive);
        }
    }

    private async Task RunForProjFileAsync(
        string repoRootPath,
        string projFilePath,
        string dependencyName,
        string previousDependencyVersion,
        string newDependencyVersion,
        bool isTransitive)
    {
        _logger.Log($"Running for proj file [{Path.GetRelativePath(repoRootPath, projFilePath)}]");
        if (!File.Exists(projFilePath))
        {
            _logger.Log($"File [{projFilePath}] does not exist.");
            return;
        }

        var projectFilePaths = MSBuildHelper.GetProjectPathsFromProject(projFilePath);
        foreach (var projectFullPath in projectFilePaths)
        {
            // If there is some MSBuild logic that needs to run to fully resolve the path skip the project
            if (File.Exists(projectFullPath))
            {
                await RunForProjectAsync(repoRootPath, projectFullPath, dependencyName, previousDependencyVersion, newDependencyVersion, isTransitive);
            }
        }
    }

    private async Task RunForProjectAsync(
        string repoRootPath,
        string projectPath,
        string dependencyName,
        string previousDependencyVersion,
        string newDependencyVersion,
        bool isTransitive)
    {
        _logger.Log($"Running for project file [{Path.GetRelativePath(repoRootPath, projectPath)}]");
        if (!File.Exists(projectPath))
        {
            _logger.Log($"File [{projectPath}] does not exist.");
            return;
        }

        var projectFilePaths = MSBuildHelper.GetProjectPathsFromProject(projectPath);
        foreach (var projectFullPath in projectFilePaths.Concat([projectPath]))
        {
            // If there is some MSBuild logic that needs to run to fully resolve the path skip the project
            if (File.Exists(projectFullPath))
            {
                await RunUpdaterAsync(repoRootPath, projectFullPath, dependencyName, previousDependencyVersion, newDependencyVersion, isTransitive);
            }
        }
    }

    private async Task RunUpdaterAsync(
        string repoRootPath,
        string projectPath,
        string dependencyName,
        string previousDependencyVersion,
        string newDependencyVersion,
        bool isTransitive)
    {
        if (_processedProjectPaths.Contains(projectPath))
        {
            return;
        }

        _processedProjectPaths.Add(projectPath);

        _logger.Log($"Updating project [{projectPath}]");

        if (NuGetHelper.TryGetPackagesConfigFile(projectPath, out var packagesConfigPath))
        {
            await PackagesConfigUpdater.UpdateDependencyAsync(repoRootPath, projectPath, dependencyName, previousDependencyVersion, newDependencyVersion, packagesConfigPath, _logger);
        }

        // Some repos use a mix of packages.config and PackageReference
        await SdkPackageUpdater.UpdateDependencyAsync(repoRootPath, projectPath, dependencyName, previousDependencyVersion, newDependencyVersion, isTransitive, _logger);
    }
}
