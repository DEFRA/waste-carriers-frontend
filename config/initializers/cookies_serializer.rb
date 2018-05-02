# Be sure to restart your server when you modify this file.

# In waste-carriers-renewals this is set to json, which is actually the default
# for 4.2.10. Previously in the frontend this file did not exist until we
# needed to get the two talking, and it was using Marshal. To support apps
# upgrading you can set a value of hybrid, which essentially means rails will
# handle users coming with an old style cookie to your app and automatically
# convert it to json.
#
# At somepoint in the future you are recommended to switch it to :json, at a
# point you are confident all users cookies have been converted. This issue
# put us onto the change in serializer between versions and the use of :hybrid
# https://github.com/rails/rails/issues/15111 
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
