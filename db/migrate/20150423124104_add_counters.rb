class AddCounters < ActiveRecord::Migration
  def up
    table_counters.each do |table, counters|
      counters.each do |counter|
        unless column_exists?(table, counter)
          add_column table, counter, :integer, null: false, default: 0
          klass = table.to_s.classify.constantize
          klass.reset_column_information
          klass.pluck(:id).each do |object_id|
            klass.reset_counters object_id, counter[0..-7]
          end
        end
      end
    end
  end

  def down
    table_counters.each do |table, counters|
      counters.each do |counter|
        if column_exists?(table, counter)
          remove_column table, counter
        end
      end
    end
  end

  def table_counters
    {
      plant_populations: [
        :plant_population_lists_count,
        :linkage_maps_count,
        :plant_trials_count
      ]
    }
  end
end
