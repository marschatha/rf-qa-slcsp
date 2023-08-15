require_relative '../../lib/second_lowest_cost_silver_plan'

RSpec.describe SecondLowestCostSilverPlan do
  before { stub_csv_paths }
  after { reset_slcsp_csv }

  describe '#generate' do
    it 'updates the csv with slcsp values' do
      input_csv = File.read('./spec/support/csvs/slcsp.csv')
      expected_output = <<~CSV
        zipcode,rate
        64148,245.2
        67118,212.35
        40813,
        54923,
      CSV

      expect { SecondLowestCostSilverPlan.new.generate }
        .to change { File.read('./spec/support/csvs/slcsp.csv') }
        .from(input_csv)
        .to(expected_output)
        .and output(expected_output).to_stdout
    end
  end

  def stub_csv_paths
    stub_const('SecondLowestCostSilverPlan::SLCSP_CSV', './spec/support/csvs/slcsp.csv')
    stub_const('SecondLowestCostSilverPlan::ZIPS_CSV', './spec/support/csvs/zips.csv')
    stub_const('SecondLowestCostSilverPlan::PLANS_CSV', './spec/support/csvs/plans.csv')
  end

  def reset_slcsp_csv
    rows = [['zipcode', 'rate']]

    CSV.open('./spec/support/csvs/slcsp.csv', headers: true) do |csv|
      csv.each {|row| rows << [row['zipcode'], nil] }
    end

    CSV.open('./spec/support/csvs/slcsp.csv', 'w+') do |csv|
      rows.each {|row| csv << row }
    end
  end
end
