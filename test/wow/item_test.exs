defmodule Wow.ItemTest do
  use Wow.DataCase

  describe "item" do
    alias Wow.Item

    @valid_raw %{"id" => 36472, "disenchantingSkillRank" => 0, "description" => "", "name" => "Carved Rod",
      "icon" => "inv_misc_branch_01", "stackable" => 1, "itemBind" => 2,
      "bonusStats" => [%{"stat" => 5, "amount" => 40}, %{"stat" => 7, "amount" => 20}],
      "itemSpells" => [], "buyPrice" => 367439, "itemClass" => 4, "itemSubClass" => 0, "containerSlots" => 0,
      "inventoryType" => 23, "equippable" => true, "itemLevel" => 100, "maxCount" => 0, "maxDurability" => 0,
      "minFactionId" => 0, "minReputation" => 0, "quality" => 2, "sellPrice" => 73487, "requiredSkill" => 0,
      "requiredLevel" => 80, "requiredSkillRank" => 0, "itemSource" => %{"sourceId" => 0, "sourceType" => "NONE"},
      "baseArmor" => 0, "hasSockets" => false, "isAuctionable" => true}

    test "from_raw/1 builds an item" do
      assert entry = Item.from_raw(@valid_raw)
      assert entry.valid?
      assert entry.data.blob["itemClass"] == 4
    end

    test "from_raw/1 validates values" do
      assert entry = Item.from_raw(Map.delete(@valid_raw, "id"))
      refute entry.valid?
    end
  end
end
