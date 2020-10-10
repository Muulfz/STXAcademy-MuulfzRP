Inventories = {}

function allowDrop(event) {
    event.preventDefault();
}

function drop(event, target) {
    let eventSlotId = event.dataTransfer.getData("slot_id")
    let targetSlotId = target.parentElement.id.split('-')[0]

    let eventInventory = Inventories[event.dataTransfer.getData("inventory_id")]
    let targetInventory = Inventories[target.parentElement.getAttribute("data-inventoryid")]

    if (targetSlotId) {
        moveSlot(eventInventory.slots[eventSlotId], eventInventory, eventSlotId,
            targetInventory.slots[targetSlotId], targetInventory, targetSlotId)
    }
}

function RegisterInventoryTransaction(dragInventory, dropSlotId, dragSlotId) {
    //TODO Send do server this info
}

function RegisterInventoryExternalTransaction(dragInventory, dragSlotId, dropInventory, dropSlotId) {
    //Todo Send to  the server this info
}

window.addEventListener('message', (message) => {
    console.log(message)
    if (message.data.event === "CreateNewInventory") {
        let data = message.data.data;
        let inventory = new Inventory(data.id, data.name, data.weight, data.slotNumber);
        inventory.Show();
        inventory.AddBulkSlot(data.slots());

    }
})

function CreateInventory(id, name, maxWeight, slotNumber) {
    new Inventory(id, name, maxWeight, slotNumber);
}

function UpdateInventory(id, inventory) {
    let inventoryElement = Inventory[id];
    inventoryElement.name = inventory.name;
    inventoryElement.maxWeight = inventory.maxWeight;
    inventoryElement.slots = inventory.maxWeight;
    inventoryElement.slotNumber = inventory.slotNumber;

    inventoryElement.UpdateInventoryUI();
    for (let i = 0; i < inventoryElement.slots.length; i++) {
        inventoryElement.UpdateSlotGraphics(i)
    }
}

function moveSlot(dropSlot, dropInventory, dropSlotId, dragSlot, dragInventory, dragSlotId) {
    let dragItem = dragSlot.item;
    let dropItem = dropSlot.item;

    if ((dragItem != undefined && dropItem != undefined) && dragItem.itemName === dropItem.itemName) {
        dropSlot.itemQuantity = dropSlot.itemQuantity + dragSlot.itemQuantity;
        dragInventory.RemoveItem(dragSlotId, dragSlot.itemQuantity);

    }
    const eventSlot = JSON.stringify(dragInventory.slots[dragSlotId]);
    const targetSlot = JSON.stringify(dropInventory.slots[dropSlotId]);

    dragInventory.slots[dragSlotId] = JSON.parse(targetSlot);
    dropInventory.slots[dropSlotId] = JSON.parse(eventSlot);


    dragInventory.UpdateSlotGraphics(dragSlotId);
    dropInventory.UpdateSlotGraphics(dropSlotId);


    if (dragInventory.id === dropInventory.id) {
        RegisterInventoryTransaction(dragInventory, dropSlotId, dragSlotId);
    } else {
        RegisterInventoryExternalTransaction(dragInventory, dragSlotId, dropInventory, dropSlotId);
    }
}

function drag(event) {
    event.dataTransfer.setData("slot_id", event.target.parentElement.id.split('-')[0])
    event.dataTransfer.setData("inventory_id", event.target.parentElement.getAttribute("data-inventoryid"))
}

function create_UUID() {
    let dt = new Date().getTime();
    const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        const r = (dt + Math.random() * 16) % 16 | 0;
        dt = Math.floor(dt / 16);
        return (c == 'x' ? r : (r & 0x3 | 0x8)).toString(16);
    });
    return uuid;
}

class Inventory {
    id;
    name;
    weight;
    maxWeight;
    slotNumber;
    slots;

    constructor(id, name, maxWeight, slotNumber) {
        this.name = name;
        this.weight = 0;
        this.maxWeight = maxWeight;
        this.slotNumber = slotNumber;
        this.slots = {}
        this.id = create_UUID();
        Inventories[this.id] = this;
    }

    Show() {
        this.GenerateInventory();
        this.GenerateSlots();
    }

    GenerateInventory() {
        $('.root').append(
            `<div class="inventory-card" data-inventoryid = ${this.id}>
                 <div class="inventory-header">
                        <div class="inventory-name-title">
                            <div class="inventory-name" id="inventory-name${this.id}"></div>
                        </div>
                        <div class="inventory-weight">
                            <div class="weight-bar">
                                <div class="weight-bar-value" id="weight-bar-value-${this.id}">
                                    <div class="weight-bar-value-percentage" id="weight-bar-value-percentage-${this.id}">
                                    </div>
                                </div>
                            </div>
                            <div class="weight-bar-kg" id="weight-bar-kg-${this.id}">
                            </div>
                        </div>
                        <div class="inventory-close">
                            <i class="fas fa-times"></i>
                        </div>
                 </div>
                 <div class="inventory_body">
                        <div class="inventory-slots" id="${this.id}">
                        </div>
                 </div>
             </div>`
        )
    }

    GenerateSlots() {
        for (let i = 1; i < this.slotNumber; i++) {
            $(`#${this.id}`).append(`
         <div class="inventory-slot-block" id="${i + "-" + this.id}" data-inventoryid = "${this.id}">
                <div class="inventory-slot-card" ondragover="allowDrop(event)" ondrop="drop(event, this)" draggable="true" ondragstart="drag(event)">
                </div>
            </div>
        `);
            this.slots[i] = this.GenerateEmptySlot();
        }
        this.UpdateInventoryUI()
    }

    AddItem(item, quantity) {
        for (let id = 1; id < this.slotNumber; id++) {
            if (this.slots[id].isEmpty) {
                this.SetSlotItem(id, item, quantity)
                return true;
            }
        }
        return false;
    }

    RemoveItem(slotId, quantity) {
        let slot = this.slots[slotId];

        if (slot.itemQuantity >= quantity && !slot.isEmpty) {
            if (slot.itemQuantity <= quantity) {
                this.slots[slotId] = this.GenerateEmptySlot();
            } else {
                slot.itemQuantity = slot.itemQuantity - quantity;
            }
            this.weight = this.weight - (slot.weight * quantity);

            this.UpdateSlotGraphics(slotId);
            return true;
        }
        return false;
    }

    UpdateSlotGraphics(slotId) {
        let slot = this.slots[slotId]
        let slotElement = $(`#${slotId + "-" + this.id}`).children();

        slotElement.empty();

        if (!slot.isEmpty) {
            let card = this.GenerateItem(slot.item, slot.itemQuantity);

            slotElement.append(card);
        }

        this.UpdateInventoryUI();
    }

    GenerateItem(item, quantity) {
        return `<div class="inventory-item-count">
                        <div class="inventory-item-count-value">${quantity}X</div>
                    </div>
                    <div class="inventory-slot-card-title">
                        <div class="inventory-item-title">
                            ${item.itemName}
                        </div>
                    </div>
                    <div class="inventory-item-image" style="background-image: url(${item.img})" draggable="false" ></div>
              `
    }

    AddBulkSlot(slots) {
        this.slots = slots;
        for (let i = 0; i < this.slots.length; i++) {
            this.UpdateSlotGraphics(i);
        }
        this.UpdateInventoryUI();
    }

    SetSlotItem(slotId, item, quantity) {
        if (this.slots[slotId].isEmpty) {

            this.slots[slotId] = {
                item: item,
                itemQuantity: quantity,
                isEmpty: false,
            };

            this.weight = this.weight + (item.weight * quantity);

            this.UpdateSlotGraphics(slotId);
            return true;
        }
        return false;
    }

    GenerateEmptySlot() {
        return {
            item: null,
            itemQuantity: 0,
            isEmpty: true
        }
    }

    UpdateWeight() {
        this.weight = 0;
        for (let i = 1; i < this.slots.length + 1; i++) {
            let slot = this.slots[i];
            if (!slot.isEmpty) {
                this.weight = this.weight + (slot.itemQuantity * slot.item.weight)
            }
        }
    }

    UpdateWeightBar() {
        this.UpdateWeight();

        let porcentage = (this.weight / this.maxWeight) * 100;

        if (porcentage >= 25) {
            $(`#weight-bar-value-percentage-${this.id}`).html(`${porcentage}%`);
        } else {
            $(`#weight-bar-value-percentage-${this.id}`).html("");
        }

        let maxWidth = $(`#weight-bar-value-${this.id}`).css('max-width').replace("px", "");
        $(`#weight-bar-value-${this.id}`).css('width', Math.round((maxWidth / 100) * porcentage))

        if (porcentage >= 90) {
            $(`#weight-bar-value-${this.id}`).css('background', '#723333');
        } else {
            $(`#weight-bar-value-${this.id}`).css('background', '#3F7233');
        }
    }

    UpdateMaxWeight() {
        $(`#weight-bar-kg-${this.id}`).html(`${this.maxWeight}KG`)
    }

    UpdateInventoryName() {
        $(`#inventory-name${this.id}`).html(this.name)
    }

    UpdateInventoryUI() {
        this.UpdateWeight();
        this.UpdateInventoryName();
        this.UpdateWeightBar();
        this.UpdateMaxWeight();
    }

}

class Item {
    itemName;
    itemMaxStack;
    isUsable;
    isDrop;
    img;
    weight;

    constructor(itemName, itemMaxStack, isUsable, isDrop, img, weight) {
        this.itemName = itemName;
        this.itemMaxStack = itemMaxStack;
        this.isUsable = isUsable;
        this.isDrop = isDrop;
        this.img = img;
        this.weight = weight;
    }


}