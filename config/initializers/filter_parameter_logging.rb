# Be sure to restart your server when you modify this file.
#
# Parameters matching these names are replaced with [FILTERED] before they reach
# the log. This list is deliberately wider than Rails' default: order contents,
# addresses, and contact details are all health-adjacent on this site, and none
# of them belong in a log file.
#
# See docs/project-context.md section 6.
Rails.application.config.filter_parameters += [
  :passw,
  :email,
  :secret,
  :token,
  :_key,
  :crypt,
  :salt,
  :certificate,
  :otp,
  :ssn,
  :cvv,
  :cvc,
  :phone,
  :name,
  :line1,
  :line2,
  :postal_code,
  :address,
  :note,
  :question
]
