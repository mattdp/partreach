S3DirectUpload.config do |c|
  c.access_key_id = ENV['AWS_ACCESS_KEY_ID']              # your access key id
  c.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']      # your secret access key
  if Rails.env.production?
    c.bucket = "supplybetter_rfq_files"                   # your bucket name
  else
    c.bucket = "supplybetter_test_file_upload"            # your bucket name
  end
  c.region = nil                                          # region prefix of your bucket url. This is _required_ for the non-default AWS region, eg. "s3-eu-west-1"
  c.url = nil                                             # S3 API endpoint (optional), eg. "https://#{c.bucket}.s3.amazonaws.com/"
end