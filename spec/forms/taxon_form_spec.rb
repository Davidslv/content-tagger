require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'

RSpec.describe TaxonForm do
  include GdsApi::TestHelpers::PublishingApiV2

  context 'validations' do
    it 'is not valid without a title' do
      taxon_form = described_class.new
      expect(taxon_form).to_not be_valid
      expect(taxon_form.errors.keys).to include(:title)
    end
  end

  describe '.build' do
    let(:content_id) { SecureRandom.uuid }
    let(:subject) { described_class.build(content_id: content_id) }
    let(:content) do
      {
        content_id: content_id,
        title: 'A title',
        base_path: 'A base path'
      }
    end

    before do
      publishing_api_has_item(content)
      publishing_api_has_links(
        content_id: content_id,
        links: {
          topics: [],
          parent_taxons: []
        }
      )
    end

    it 'assigns the parents to the form' do
      expect(subject.parent_taxons).to be_empty
    end

    it 'assigns the content id correctly' do
      expect(subject.content_id).to eq(content_id)
    end

    it 'assigns the title correctly' do
      expect(subject.title).to eq(content[:title])
    end

    it 'assigns the base_path correctly' do
      expect(subject.base_path).to eq(content[:base_path])
    end

    context 'without taxon parents' do
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: {
            topics: []
          }
        )
      end

      it 'has no taxon parents' do
        expect(subject.parent_taxons).to be_empty
      end
    end

    context 'with existing links' do
      let(:parent_taxons) { ["CONTENT-ID-RTI", "CONTENT-ID-VAT"] }
      before do
        publishing_api_has_links(
          content_id: content_id,
          links: {
            topics: [],
            parent_taxons: parent_taxons
          }
        )
      end

      it 'assigns the parents to the form' do
        expect(subject.parent_taxons).to eq(parent_taxons)
      end
    end
  end
end