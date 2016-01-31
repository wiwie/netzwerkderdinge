# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersAssoziationsInsertOrAssoziationsDelete < ActiveRecord::Migration
  def up
    create_trigger("trigger_increase_indegree", :generated => true, :compatibility => 1).
        on("assoziations").
        name("trigger_increase_indegree").
        after(:insert) do
      "UPDATE dings SET indegree = indegree + 1 WHERE id = NEW.ding_zwei_id;"
    end

    create_trigger("trigger_increase_outdegree", :generated => true, :compatibility => 1).
        on("assoziations").
        name("trigger_increase_outdegree").
        after(:insert) do
      "UPDATE dings SET outdegree = outdegree + 1 WHERE id = NEW.ding_eins_id;"
    end

    create_trigger("trigger_decrease_indegree", :generated => true, :compatibility => 1).
        on("assoziations").
        name("trigger_decrease_indegree").
        after(:delete) do
      "UPDATE dings SET indegree = indegree - 1 WHERE id = OLD.ding_zwei_id;"
    end

    create_trigger("trigger_decrease_oudegree", :generated => true, :compatibility => 1).
        on("assoziations").
        name("trigger_decrease_oudegree").
        after(:delete) do
      "UPDATE dings SET outdegree = outdegree - 1 WHERE id = OLD.ding_eins_id;"
    end
  end

  def down
    drop_trigger("trigger_increase_indegree", "assoziations", :generated => true)

    drop_trigger("trigger_increase_outdegree", "assoziations", :generated => true)

    drop_trigger("trigger_decrease_indegree", "assoziations", :generated => true)

    drop_trigger("trigger_decrease_oudegree", "assoziations", :generated => true)
  end
end
