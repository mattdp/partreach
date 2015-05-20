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

  #code for secure pictures, while WIP
  def get_expiring_url

    return nil unless (
      consumer_type == "Provider" and 
      provider = Provider.find_by_id(consumer_id) and
      organization = provider.organization and
      organization.external_bucket_name.present?
      )

    region = "us-east-1"

    #hitting the token vending service
    sts = Aws::STS::Client.new(
      region: region,
      access_key_id: ENV['SB_CLIENTS_SYNAPSE_ACCESS_KEY'],
      secret_access_key: ENV['SB_CLIENTS_SYNAPSE_SECRET_KEY']
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

    s3_resource.bucket(organization.external_bucket_name) \
      .object(self.remote_file_name) \
      .presigned_url(:get, expires_in: 15*60)
  end

end
