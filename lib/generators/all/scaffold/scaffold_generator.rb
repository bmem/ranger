# From http://stackoverflow.com/a/18533215/595286

require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'

module All # :nodoc:
  module Generators # :nodoc:
    class ScaffoldGenerator < Rails::Generators::NamedBase # :nodoc:
      include Rails::Generators::ResourceHelpers

      source_root File.join(Rails.root, 'lib', 'templates', 'scaffold', File::SEPARATOR)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_root_folder
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          template view, File.join("app/views", controller_file_path, view)
        end
      end

    protected
      def available_views
        # use all template files contained in source_root ie 'lib/templates/scaffold/**/*'
        base = self.class.source_root
        base_len = base.length
        Dir[File.join(base, '**', '*')].select { |f| File.file?(f) }.map{|f| f[base_len..-1]}
      end
    end
  end
end
