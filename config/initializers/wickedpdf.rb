if ENV.has_key?('WCRS_USE_XVFB_FOR_WICKEDPDF')
  WickedPdf.config = {
    exe_path: Rails.root.join('script', 'wkhtmltopdf.sh').to_s
  }
end
