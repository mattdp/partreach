# == Schema Information
#
# Table name: externals
#
#  id                :integer          not null, primary key
#  url               :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  consumer_id       :integer
#  consumer_type     :string(255)
#  units             :string(255)
#  original_filename :string(255)
#  remote_file_name  :string(255)
#

class External < ActiveRecord::Base
  belongs_to :consumer, polymorphic: true

  validates :consumer_id, presence: true
  validates :consumer_type, presence: true
  validates :url, presence: true

  def self.setup_s3_resource(organization)
    region = "us-east-1"

    #hitting the token vending service
    sts = Aws::STS::Client.new(
      region: region,
      access_key_id: ENV[organization.external_bucket_env_var_access],
      secret_access_key: ENV[organization.external_bucket_env_var_secret]
      )
    #getting a temporary session token
    token = sts.get_session_token(
      duration_seconds: 15*60 #minimum 15m from amazon I believe
      )
    #setting up credentials for S3 with that token
    credentials = Aws::Credentials.new(
      token[:credentials][:access_key_id], 
      token[:credentials][:secret_access_key],
      token[:credentials][:session_token]
      )
    #s3 api client - need this for resource
    s3_client = Aws::S3::Client.new(
      region: region,
      credentials: credentials
      )
    # allows .bucket and .object, so i can get an Object for .presigned_url
    s3_resource = Aws::S3::Resource.new(
      region: region,
      client: s3_client
      )
    return s3_resource
  end

  #all work that only needs to be done once per fetching of photos
  def self.get_expiring_urls(externals_list,organization)

    return nil unless externals_list.present?

    s3_resource = External.setup_s3_resource(organization)

    result = [] 
    externals_list.each do |external|
      url = external.get_expiring_url_helper(s3_resource)
      result << url if url.present?
    end
    return result

  end

  def get_expiring_url_helper(s3_resource)

    return nil unless (
      consumer_type == "Provider" and 
      provider = Provider.find_by_id(self.consumer_id) and
      organization = provider.organization and
      organization.external_bucket_name.present?
      )

    s3_resource.bucket(organization.external_bucket_name) \
      .object(self.remote_file_name) \
      .presigned_url(:get, expires_in: 15*60)

  end

end
