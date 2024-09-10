# typed: false
# frozen_string_literal: true

require "dependabot/version"
require "dependabot/package_manager"
require "dependabot/notices"

# A stub package manager for testing purposes.
class StubPackageManager < Dependabot::PackageManagerBase
  def initialize(name:, version:, deprecated_versions: [], unsupported_versions: [], supported_versions: [],
                 support_later_versions: false)
    @name = name
    @version = version
    @deprecated_versions = deprecated_versions
    @unsupported_versions = unsupported_versions
    @supported_versions = supported_versions
    @support_later_versions = support_later_versions
  end

  attr_reader :name
  attr_reader :version
  attr_reader :deprecated_versions
  attr_reader :unsupported_versions
  attr_reader :supported_versions
  attr_reader :support_later_versions
end

RSpec.describe Dependabot::Notice do
  describe ".generate_supported_versions_description" do
    subject(:generate_supported_versions_description) do
      described_class.generate_supported_versions_description(supported_versions, support_later_versions)
    end

    context "when supported_versions has one version" do
      let(:supported_versions) { [Dependabot::Version.new("2")] }
      let(:support_later_versions) { false }

      it "returns the correct description" do
        expect(generate_supported_versions_description)
          .to eq("Please upgrade to version `v2`.")
      end
    end

    context "when supported_versions has one version and later versions are supported" do
      let(:supported_versions) { [Dependabot::Version.new("2")] }
      let(:support_later_versions) { true }

      it "returns the correct description" do
        expect(generate_supported_versions_description)
          .to eq("Please upgrade to version `v2`, or later.")
      end
    end

    context "when supported_versions has multiple versions" do
      let(:supported_versions) do
        [Dependabot::Version.new("2"), Dependabot::Version.new("3"),
         Dependabot::Version.new("4")]
      end
      let(:support_later_versions) { false }

      it "returns the correct description" do
        expect(generate_supported_versions_description)
          .to eq("Please upgrade to one of the following versions: `v2`, `v3`, or `v4`.")
      end
    end

    context "when supported_versions has multiple versions and later versions are supported" do
      let(:supported_versions) do
        [Dependabot::Version.new("2"), Dependabot::Version.new("3"),
         Dependabot::Version.new("4")]
      end
      let(:support_later_versions) { true }

      it "returns the correct description" do
        expect(generate_supported_versions_description)
          .to eq("Please upgrade to one of the following versions: `v2`, `v3`, `v4`, or later.")
      end
    end

    context "when supported_versions is nil" do
      let(:supported_versions) { nil }
      let(:support_later_versions) { false }

      it "returns empty string" do
        expect(generate_supported_versions_description).to eq("Please upgrade your package manager version")
      end
    end

    context "when supported_versions is empty" do
      let(:supported_versions) { [] }
      let(:support_later_versions) { false }

      it "returns nil" do
        expect(generate_supported_versions_description).to eq("Please upgrade your package manager version")
      end
    end
  end

  describe ".generate_support_notice" do
    subject(:generate_support_notice) do
      described_class.generate_support_notice(package_manager)
    end

    let(:package_manager) do
      StubPackageManager.new(
        name: "bundler",
        version: Dependabot::Version.new("1"),
        deprecated_versions: deprecated_versions,
        unsupported_versions: unsupported_versions,
        supported_versions: supported_versions
      )
    end

    let(:supported_versions) { [Dependabot::Version.new("2"), Dependabot::Version.new("3")] }
    let(:deprecated_versions) { [Dependabot::Version.new("1")] }
    let(:unsupported_versions) { [] }

    context "when the package manager is deprecated" do
      let(:unsupported_versions) { [] }

      it "returns the correct support notice" do
        expect(generate_support_notice.to_hash)
          .to eq({
            mode: "WARN",
            type: "bundler_deprecated_warn",
            package_manager_name: "bundler",
            title: "Package manager deprecation notice",
            description: "Dependabot will stop supporting `bundler v1`!" \
                         "\n\nPlease upgrade to one of the following versions: `v2`, or `v3`.\n",
            show_in_pr: true,
            show_alert: true
          })
      end
    end

    context "when the package manager is unsupported" do
      let(:deprecated_versions) { [] }
      let(:unsupported_versions) { [Dependabot::Version.new("1")] }

      it "returns the correct support notice" do
        expect(generate_support_notice.to_hash)
          .to eq({
            mode: "ERROR",
            type: "bundler_unsupported_error",
            package_manager_name: "bundler",
            title: "Package manager unsupported notice",
            description: "Dependabot no longer supports `bundler v1`!" \
                         "\n\nPlease upgrade to one of the following versions: `v2`, or `v3`.\n",
            show_in_pr: true,
            show_alert: true
          })
      end
    end

    context "when the package manager is neither deprecated nor unsupported" do
      let(:version) { Dependabot::Version.new("2") }
      let(:supported_versions) do
        [Dependabot::Version.new("2"), Dependabot::Version.new("3"),
         Dependabot::Version.new("4")]
      end
      let(:deprecated_versions) { [] }
      let(:unsupported_versions) { [] }
      let(:package_manager) do
        StubPackageManager.new(
          name: "bundler",
          version: Dependabot::Version.new("2"),
          deprecated_versions: deprecated_versions,
          unsupported_versions: unsupported_versions,
          supported_versions: supported_versions
        )
      end

      it "returns nil" do
        expect(generate_support_notice).to be_nil
      end
    end
  end

  describe ".generate_pm_deprecation_notice" do
    subject(:generate_pm_deprecation_notice) do
      described_class.generate_pm_deprecation_notice(package_manager)
    end

    let(:package_manager) do
      StubPackageManager.new(
        name: "bundler",
        version: Dependabot::Version.new("1"),
        deprecated_versions: [Dependabot::Version.new("1")],
        supported_versions: [Dependabot::Version.new("2"), Dependabot::Version.new("3")]
      )
    end

    it "returns the correct deprecation notice" do
      expect(generate_pm_deprecation_notice.to_hash)
        .to eq({
          mode: "WARN",
          type: "bundler_deprecated_warn",
          package_manager_name: "bundler",
          title: "Package manager deprecation notice",
          description: "Dependabot will stop supporting `bundler v1`!" \
                       "\n\nPlease upgrade to one of the following versions: `v2`, or `v3`.\n",
          show_in_pr: true,
          show_alert: true
        })
    end
  end

  describe ".generate_pm_unsupported_notice" do
    subject(:generate_pm_unsupported_notice) do
      described_class.generate_pm_unsupported_notice(package_manager)
    end

    let(:package_manager) do
      StubPackageManager.new(
        name: "bundler",
        version: Dependabot::Version.new("1"),
        supported_versions: supported_versions
      )
    end
    let(:supported_versions) { [Dependabot::Version.new("2"), Dependabot::Version.new("3")] }

    it "returns the correct unsupported notice" do
      expect(generate_pm_unsupported_notice.to_hash)
        .to eq({
          mode: "ERROR",
          type: "bundler_unsupported_error",
          package_manager_name: "bundler",
          title: "Package manager unsupported notice",
          description: "Dependabot no longer supports `bundler v1`!" \
                       "\n\nPlease upgrade to one of the following versions: `v2`, or `v3`.\n",
          show_in_pr: true,
          show_alert: true
        })
    end
  end
end
