# from https://github.com/rails/rails/pull/6069
module ActiveRecord::ConnectionAdapters
  if Object.const_defined? 'Mysql2Adapter'
    class Mysql2Adapter

    private
      alias_method :configure_connection_without_strict_mode, :configure_connection

      def configure_connection
        configure_connection_without_strict_mode
        strict_mode = "SQL_MODE='STRICT_ALL_TABLES'"
        execute("SET #{strict_mode}", :skip_logging)
      end
    end
  end
end
