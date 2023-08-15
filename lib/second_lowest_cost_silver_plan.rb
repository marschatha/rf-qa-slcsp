# frozen_string_literal: true

require 'CSV'

class SecondLowestCostSilverPlan
  METAL_LEVEL = 'Silver'
  SLCSP_CSV = 'slcsp.csv'
  PLANS_CSV = 'plans.csv'
  ZIPS_CSV = 'zips.csv'

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
    zip_rows = read_csv(ZIPS_CSV).select do |row|
      row['zipcode'] == zipcode
    end

    rate_areas = zip_rows.map {|row| row['rate_area'] }
    rate_areas.uniq!
    return nil if rate_areas.length != 1

    zip_rows.first
  end

  def find_silver_plan_rates(zip_data)
    read_csv(PLANS_CSV).filter_map do |plan|
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
end
