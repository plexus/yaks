require 'integration_helper'

RSpec.describe 'Sinatra Modular app integration', type: :integration do
  include Yaks::Sinatra::Test::ModularApp::Helpers

  ::Yaks::Format.all.each do |format|
    context "For #{format.format_name}" do
      it "returns 200" do
        make_req(format.media_type)
        expect(last_response).to be_ok
      end

      it "respects the Accept header" do
        make_req(format.media_type)
        expect(last_content_type.type).to eq(format.media_type)
      end

      it "returns an explicit charset" do
        make_req(format.media_type)
        expect(last_content_type.charset).to eq('utf-8')
      end
    end
  end
end
