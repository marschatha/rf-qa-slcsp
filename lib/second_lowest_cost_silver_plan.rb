# frozen_string_literal: true

require 'CSV'

class SecondLowestCostSilverPlan
  METAL_LEVEL = 'Silver'
  SLCSP_CSV = 'slcsp.csv'
  PLANS_CSV = 'plans.csv'
  ZIPS_CSV = 'zips.csv'
  MEMORY_SAFE_CSV_SIZE = 20_971_520 # 20 MB in bytes

  def generate
    write_to_csv(generate_data)
    puts File.read(SLCSP_CSV)
  end

  private

  def generate_data
    read_csv(SLCSP_CSV).map do |row|
      zipcode = row['zipcode']
      slcsp = find_slcsp(zipcode)

      [zipcode, slcsp]
    end
  end

  def write_to_csv(data)
    CSV.open(SLCSP_CSV, 'w+') do |csv|
      csv << ['zipcode',	'rate']
      data.each {|row| csv << row }
    end
  end

  def find_slcsp(zipcode)
    zip_data = find_zip_data(zipcode)
    return nil if zip_data.nil?

    find_second_lowest_rate(find_silver_plan_rates(zip_data))
  end

  def find_zip_data(zipcode)
    zip_rows = zips_csv.select do |row|
      row['zipcode'] == zipcode
    end

    rate_areas = zip_rows.map {|row| row['rate_area'] }
    rate_areas.uniq!
    return nil if rate_areas.length != 1

    zip_rows.first
  end

  def find_silver_plan_rates(zip_data)
    plans_csv.filter_map do |plan|
      plan['rate'] if plan['metal_level'] == METAL_LEVEL &&
                      plan['state'] == zip_data['state'] &&
                      plan['rate_area'] == zip_data['rate_area']
    end
  end

  def find_second_lowest_rate(rates)
    rates.delete(rates.min) # remove the lowest rate(s)
    rates.min
  end

  def read_csv(name)
    CSV.foreach(name, headers: true)
  end

  # load small csvs into memory for faster processing
  def plans_csv
    if File.size(PLANS_CSV) < MEMORY_SAFE_CSV_SIZE
      @plans_csv ||= read_csv(PLANS_CSV).to_a
    else
      read_csv(PLANS_CSV)
    end
  end

  def zips_csv
    if File.size(ZIPS_CSV) < MEMORY_SAFE_CSV_SIZE
      @zips_csv ||= read_csv(ZIPS_CSV).to_a
    else
      read_csv(ZIPS_CSV)
    end
  end
end
