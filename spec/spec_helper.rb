# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "bundler/setup"
require "smuggle"
require "faker"
require "pry"
require "pry-byebug"

require "support/dummy_user_relation"
require "support/user"
require "support/exporters/user_exporter"
require "support/exporters/with_attributes"
require "support/exporters/without_attributes"
require "support/exporters/with_attributes_and_labels"
require "support/importers/user_importer"
require "support/importers/empty_importer"
require "support/importers/base_importer"
require "support/importers/basic_user_importer"
require "support/importers/combine_importer"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def build_records(count)
    Array.new(count) { build_record }
  end

  def build_record
    User.new(Faker::TvShows::RickAndMorty.character, Faker::TvShows::RickAndMorty.location)
  end
end
