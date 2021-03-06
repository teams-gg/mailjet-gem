# encoding: utf-8
require 'active_support'

module Mailjet
  class ApiError < StandardError

    attr_accessor :code, :reason, :response_json

    def initialize(code, res, request, request_path, params)
      self.code = code
      self.reason = ""
      self.response_json = {}
      unless res.blank?
        resdec = ActiveSupport::JSON.decode(res)
        self.response_json = resdec
        self.reason = resdec['ErrorMessage']
      end
      # code is ugly, output is pretty
      super("error #{code} while sending #{request.inspect} to #{request_path} with #{params.inspect}\n\n" +
        if res.respond_to?(:[]) && res['errors'].present?
          [(res['errors'] || [])].flatten.map do |param, text|
            [param, text].map(&:to_s).reject(&:blank?).join(': ')
          end.join("\n")
        else
          res.inspect
        end + "\n\nPlease see https://dev.mailjet.com/guides/#status-codes for more informations on error numbers.\n\n"
      )
    end
  end
end
