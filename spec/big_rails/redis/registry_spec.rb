# frozen_string_literal: true

RSpec.describe BigRails::Redis::Registry do
  subject(:instance) { described_class.new }

  before { load_config("simple") }

  describe "#for" do
    context "when name is not valid" do
      it "raises error" do
        expect {
          instance.for("foo")
        }.to raise_error(described_class::UnknownConnection, "connection for 'foo' is not registered")
      end
    end

    it "stores connection" do
      expect(instance.builder).to receive(:call).and_call_original.once
      expect(instance.for("default")).to be_a(::Redis)
      # Second call should not build connection again
      instance.for("default")
    end

    context "with pool options" do
      it "returns connection pool" do
        expect(instance.for("pooled")).to be_a(::ConnectionPool)
      end
    end

    context "when wrapped" do
      it "stores wrapped connection" do
        expect(instance.for("pooled", wrapped: true).wrapped_pool).to be_a(::ConnectionPool)
      end

      context "when has no pool" do
        it "returns redis instance" do
          expect(instance.for("default", wrapped: true)).to be_a(::Redis)
          expect(instance.for("default", wrapped: true)).not_to respond_to(:wrapped_pool)
        end
      end
    end
  end

  describe "#config_for" do
    it "returns config for specific connection" do
      expect(instance.config_for("default")).to eq(
        url: "redis://localhost"
      )

      expect(instance.config_for("pooled")).to eq(
        url: "redis://localhost/2",
        pool_timeout: 5,
        pool_size: 5
      )
    end
  end

  describe "#each" do
    it "iterates through all connections" do
      instance.each do |conn|
        if conn.is_a?(::Redis)
          expect(conn).to eq(instance.for("default"))
        elsif conn.is_a?(::ConnectionPool)
          expect(conn).to eq(instance.for("pooled"))
        end
      end
    end
  end

  describe "#verify!" do
    context "with name" do
      it "verifies specified connection" do
        conn = instance.for("default")
        conn2 = instance.for("pooled")
        expect(conn).to receive(:quit).and_call_original
        conn2.with do |redis|
          expect(redis).to receive(:quit).and_call_original
        end

        instance.verify!("default")
        instance.verify!("pooled")
      end
    end

    context "without" do
      it "verifies all connections" do
        conn = instance.for("default")
        conn2 = instance.for("pooled")
        expect(conn).to receive(:quit).and_call_original
        conn2.with do |redis|
          expect(redis).to receive(:quit).and_call_original
        end

        instance.verify!
      end
    end
  end
end
