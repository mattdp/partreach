desc 'prepend http:// to supplier urls as needed'
task :prepend_http => :environment do
  sql = <<-SQL
    UPDATE suppliers
    SET url_main = 'http://' || url_main
    WHERE url_main NOT LIKE 'http%'
  SQL
  Supplier.connection.execute(sql)
end