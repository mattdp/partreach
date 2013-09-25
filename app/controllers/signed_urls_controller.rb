class SignedUrlsController < ApplicationController
  S3_BUCKET = 'partreach_initial_bucket'
  AWS_SECRET_KEY_ID = ENV['AWS_SECRET_ACCESS_KEY']
  
  def index
    render json: {
      policy: s3_upload_policy_document,
      signature: s3_upload_signature,
      key: "uploads/#{Order.all.count}_#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}_#{params[:doc][:title]}",
      success_action_redirect: "/"
    }
  end

  private

  # generate the policy document that amazon is expecting.
  def s3_upload_policy_document
    Base64.encode64(
      {
        expiration: 30.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
        conditions: [
          { bucket: S3_BUCKET },
          { acl: 'public-read' },
          ["starts-with", "$key", "uploads/"],
          { success_action_status: '201' },
          ["content-length-range", 0, 67108864]
        ]
      }.to_json
    ).gsub(/\n|\r/, '')
  end

  # sign our request by Base64 encoding the policy document.
  def s3_upload_signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        AWS_SECRET_KEY_ID,
        s3_upload_policy_document
      )
    ).gsub(/\n/, '')
  end
end
