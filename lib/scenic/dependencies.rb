# frozen_string_literal: true

require 'active_record'
require 'scenic'

require_relative 'dependencies/version'
require_relative 'dependencies/dependency_finder'
require_relative 'dependencies/dependent_finder'

module Scenic
  # Visualize database view dependencies for Scenic
  module Dependencies
    include Scenic::Dependencies::DependencyFinder
    include Scenic::Dependencies::DependentFinder
  end
end
