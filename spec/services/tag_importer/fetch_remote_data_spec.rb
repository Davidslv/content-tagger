require 'rails_helper'

RSpec.describe TagImporter::FetchRemoteData do
  include GoogleSheetHelper

  describe "#run" do
    let(:url) { URI(tagging_spreadsheet.url) }
    let(:tagging_spreadsheet) { create(:tagging_spreadsheet) }

    context 'with a valid response' do
      before do
        good_response = double(code: '200', body: google_sheet_fixture)
        allow(Net::HTTP).to receive(:get_response).with(url).and_return(good_response)
      end

      it "retrieves data from the tagging spreadsheet URL" do
        expect(Net::HTTP).to receive(:get_response).with(url)

        TagImporter::FetchRemoteData.new(tagging_spreadsheet).run
      end

      it "creates tag mappings based on the retrieved data" do
        TagImporter::FetchRemoteData.new(tagging_spreadsheet).run

        expect(TagMapping.all.map(&:content_base_path)).to eq(%w(/content-1/ /content-1/ /content-2/))
        expect(TagMapping.all.map(&:link_type)).to eq(%w(taxons taxons taxons))
      end

      it "handles superfluous whitespace when creating tag_mappings" do
        dodgy_spreadsheet_data = empty_google_sheet(
          with_rows: [
            google_sheet_row(
              content_base_path: "/content-1/  ",
              link_title: "  Education",
              link_content_id: "  education-content-id  ",
              link_type: " taxons"
            )
          ]
        )
        response = double("DodgyResponse", code: '200', body: dodgy_spreadsheet_data)
        allow(Net::HTTP).to receive(:get_response).with(url).and_return(response)

        TagImporter::FetchRemoteData.new(tagging_spreadsheet).run

        tag_mapping = TagMapping.first
        expect(tag_mapping.content_base_path).to eq "/content-1/"
        expect(tag_mapping.link_title).to eq "Education"
        expect(tag_mapping.link_content_id).to eq "education-content-id"
        expect(tag_mapping.link_type).to eq "taxons"
      end
    end

    context 'with an invalid response' do
      before do
        bad_response = double(code: '400', body: "<html>a long page</html>")
        allow(Net::HTTP).to receive(:get_response).with(url).and_return(bad_response)
      end

      it 'does not create any taggings' do
        expect { described_class.new(tagging_spreadsheet).run }.to_not change {
          tagging_spreadsheet.tag_mappings
        }
      end

      it 'returns the error message' do
        expect(described_class.new(tagging_spreadsheet).run).to include(
          /there is a problem downloading the spreadsheet/i
        )
      end

      it 'notifies airbrake of the error' do
        expect(Airbrake).to receive(:notify)

        described_class.new(tagging_spreadsheet).run
      end
    end
  end
end
