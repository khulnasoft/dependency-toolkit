# typed: strong
# frozen_string_literal: true

require "sorbet-runtime"
require "dependabot/bundler/version"
require "dependabot/package_manager"

module Dependabot
  module Bundler
    PACKAGE_MANAGER = "bundler"

    SUPPORTED_BUNDLER_VERSIONS = T.let([
      Version.new("2")
    ].freeze, T::Array[Dependabot::Version])

    DEPRECATED_BUNDLER_VERSIONS = T.let([
      Version.new("1")
    ].freeze, T::Array[Dependabot::Version])

    class PackageManager < PackageManagerBase
      extend T::Sig

      sig { params(version: T.any(String, Dependabot::Version)).void }
      def initialize(version)
        @version = T.let(Version.new(version), Dependabot::Version)
        @name = T.let(PACKAGE_MANAGER, String)
        @deprecated_versions = T.let(DEPRECATED_BUNDLER_VERSIONS, T::Array[Dependabot::Version])
        @supported_versions = T.let(SUPPORTED_BUNDLER_VERSIONS, T::Array[Dependabot::Version])
      end

      sig { override.returns(String) }
      attr_reader :name

      sig { override.returns(Dependabot::Version) }
      attr_reader :version

      sig { override.returns(T::Array[Dependabot::Version]) }
      attr_reader :deprecated_versions

      sig { override.returns(T::Array[Dependabot::Version]) }
      attr_reader :supported_versions

      sig { override.returns(T::Boolean) }
      def deprecated?
        deprecated_versions.include?(version)
      end
      sig { override.returns(T::Boolean) }
      def unsupported?
        !deprecated? && version < supported_versions.first
      end
    end
  end
end
