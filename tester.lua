local widget = require("widget")

local function handleButtonEvent(event)
    if (event.phase == "ended") then
        print("Button was pressed and released")
    end
end

local button = widget.newButton({
    label = "Click Me",
    onEvent = handleButtonEvent,
    shape = "roundedRect",
    width = 150,
    height = 40,
    cornerRadius = 10,
    fillColor = { default={0.2, 0.6, 0.8, 1}, over={0.3, 0.7, 0.9, 1} },
    labelColor = { default={1, 1, 1, 1}, over={1, 1, 1, 1} },
})

button.x = display.contentCenterX
button.y = display.contentCenterY
