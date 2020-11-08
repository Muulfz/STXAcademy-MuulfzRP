-- a basic garage implementation

-- vehicle db
vRP.prepare("vRP/vehicles_table", [[
CREATE TABLE IF NOT EXISTS vrp_user_vehicles(
  user_id INTEGER,
  vehicle VARCHAR(100),
  CONSTRAINT pk_user_vehicles PRIMARY KEY(user_id,vehicle),
  CONSTRAINT fk_user_vehicles_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);
]])

vRP.prepare("vRP/add_vehicle","INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle) VALUES(@user_id,@vehicle)")
vRP.prepare("vRP/remove_vehicle","DELETE FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vRP/get_vehicles","SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id")
vRP.prepare("vRP/get_vehicle","SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")

-- init
async(function()
  vRP.execute("vRP/vehicles_table")
end)

-- load config

local Tools = module("vrp","lib/Tools")
local cfg = module("cfg/garages")
local cfg_inventory = module("cfg/inventory")
local vehicle_groups = cfg.garage_types
local lang = vRP.lang

local garages = cfg.garages

-- vehicle models index
local veh_models_ids = Tools.newIDGenerator()
local veh_models = {}

local garage_menus = {}

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
  if first_spawn then
    vRPclient._setVehicleModelsIndex(source, veh_models)
  end
end)


-- open trunk
function vRP.OpenTruck(user_id,player,name)
  local chestname = "u"..user_id.."veh_"..string.lower(name)
  local max_weight = cfg_inventory.vehicle_chest_weights[string.lower(name)] or cfg_inventory.default_vehicle_chest_weight

  -- open chest
  vRPclient._vc_openDoor(player, name, 5)
  vRP.openChest(player, chestname, max_weight, function()
    vRPclient._vc_closeDoor(player, name, 5)
  end)
end
-- detach trailer
function vRP.DetachTrailer(user_id,player,name)
  vRPclient._vc_detachTrailer(player, name)
end

-- detach towtruck
function vRP.detachTowTruck(user_id,player,name)
  vRPclient._vc_detachTowTruck(player, name)
end

-- detach cargobob
function vRP.CargoBob(user_id,player,name)
  vRPclient._vc_detachCargobob(player, name)
end
-- lock/unlock
function vRP.LockUnLock(user_id,player,name)
  vRPclient._vc_toggleLock(player, name)
end

