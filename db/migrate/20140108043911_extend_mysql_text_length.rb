class ExtendMysqlTextLength < ActiveRecord::Migration
  def up
    # MySQL has the following text column types
    # 1 to 255 bytes: TINYTEXT
    # 256 to 65535 bytes: TEXT
    # 65536 to 16777215 bytes: MEDIUMTEXT
    # 16777216 to 4294967295 bytes: LONGTEXT
    change_column :audits, :audited_changes, :text, limit: 20.megabytes
    change_column :messages, :body, :text, limit: 1.megabyte
    change_column :reports, :readable_parameters, :text, limit: 128.kilobytes
    change_column :reports, :report_object, :text, limit: 20.megabytes
  end

  def down
    change_column :reports, :report_object, :text
    change_column :reports, :readable_parameters, :text
    change_column :messages, :body, :text
    change_column :audits, :audited_changes, :text
  end
end
