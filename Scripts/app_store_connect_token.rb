#!/usr/bin/env ruby
require "base64"
require "json"
require "openssl"

key_id, issuer_id, key_path = ARGV
abort "usage: app_store_connect_token.rb KEY_ID ISSUER_ID KEY_PATH" unless key_path

encode = ->(value) { Base64.urlsafe_encode64(value, padding: false) }
header = encode.call({ alg: "ES256", kid: key_id, typ: "JWT" }.to_json)
now = Time.now.to_i
payload = encode.call({ iss: issuer_id, iat: now - 10, exp: now + 600, aud: "appstoreconnect-v1" }.to_json)
input = "#{header}.#{payload}"
private_key = OpenSSL::PKey.read(File.read(key_path))
der_signature = private_key.sign(OpenSSL::Digest::SHA256.new, input)
sequence = OpenSSL::ASN1.decode(der_signature)
raw_signature = sequence.value.map { |integer| integer.value.to_s(2).rjust(32, "\0") }.join
puts "#{input}.#{encode.call(raw_signature)}"

