require 'rails_helper'

RSpec.describe Taxonomy::UpdateTaxon do
  before do
    @taxon = Taxon.new(
      title: 'A Title',
      description: 'Description',
      path_prefix: "/education",
      path_slug: '/slug',
      parent: 'guid'
    )
  end
  let(:publish) { described_class.call(taxon: @taxon) }

  describe '.call' do
    context 'with a valid taxon form' do
      it 'publishes the document via the publishing API' do
        expect(Services.publishing_api).to receive(:put_content)
        expect(Services.publishing_api).to receive(:patch_links)

        expect { publish }.to_not raise_error
      end
    end

    context "when the taxon has no parent" do
      before { @taxon.parent = "" }

      it "patches the links hash with an empty array" do
        expect(Services.publishing_api).to receive(:put_content)
        expect(Services.publishing_api)
          .to receive(:patch_links)
          .with(@taxon.content_id, links: { parent_taxons: [] })

        expect { publish }.to_not raise_error
      end
    end

    context 'with an unprocessable entity error from the API' do
      let(:error) do
        GdsApi::HTTPUnprocessableEntity.new(
          422,
          "An internal error message",
          'error' => { 'message' => 'Some backend error' }
        )
      end

      before do
        allow(Services.publishing_api).to receive(:put_content).and_raise(error)
      end

      it 'raises an error with a generic message and notifies Airbrake if it is not a base path conflict' do
        allow(Services.publishing_api).to receive(:lookup_content_id).and_return(nil)
        expect(Airbrake).to receive(:notify).with(error)
        expect { publish }.to raise_error(
          Taxonomy::UpdateTaxon::InvalidTaxonError,
          /there was a problem with your request/i
        )
      end

      it 'raises an error with a specific message if it is a base path conflict' do
        allow(Services.publishing_api).to receive(:lookup_content_id).and_return(SecureRandom.uuid)
        expect { publish }.to raise_error(
          Taxonomy::UpdateTaxon::InvalidTaxonError,
          /a taxon with this slug already exists/i
        )
      end
    end
  end
end
