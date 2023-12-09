# frozen_string_literal: true

shared_examples 'a dependency finder' do
  let(:recursive) { false }
  let(:view_first) { Scenic::Dependencies::View.new(name: 'view_first', materialized: false) }
  let(:view_second) { Scenic::Dependencies::View.new(name: 'view_second', materialized: true) }
  let(:view_third) { Scenic::Dependencies::View.new(name: 'view_third', materialized: false) }

  before do
    adapter = Scenic::Adapters::Postgres.new
    adapter.create_view(
      'view_first',
      "SELECT 'foo' AS bar"
    )
    adapter.create_materialized_view(
      'view_second',
      'SELECT * FROM view_first'
    )
    adapter.create_view(
      'view_third',
      'SELECT * FROM view_first UNION SELECT * FROM view_second'
    )
  end

  context 'when the target view does not exist' do
    let(:name) { 'view0' }

    it { is_expected.to match [] }
  end

  context 'when the target view has no dependencies' do
    let(:name) { 'view_first' }

    it { is_expected.to match [] }
  end

  context 'when the target view has dependencies' do
    let(:name) { 'view_second' }

    it { is_expected.to match [Scenic::Dependencies::Dependency.new(from: view_second, to: view_first)] }
  end

  context 'when the target view has nested dependencies and recursive is false' do
    let(:name) { 'view_third' }

    let(:expected) do
      [
        Scenic::Dependencies::Dependency.new(from: view_third, to: view_first),
        Scenic::Dependencies::Dependency.new(from: view_third, to: view_second)
      ]
    end

    it { is_expected.to match expected }
  end

  context 'when the target view has nested dependencies and recursive is true' do
    let(:name) { 'view_third' }
    let(:recursive) { true }

    let(:expected) do
      [
        Scenic::Dependencies::Dependency.new(from: view_third, to: view_first),
        Scenic::Dependencies::Dependency.new(from: view_third, to: view_second),
        Scenic::Dependencies::Dependency.new(from: view_second, to: view_first)
      ]
    end

    it { is_expected.to match expected }
  end
end
