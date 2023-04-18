class ClickHandler
{
    private EasyUI@ ui;
    private Component@ component;

    private bool pressed = false;

    ClickHandler(EasyUI@ ui, Component@ component)
    {
        @this.ui = ui;
        @this.component = component;
    }

    bool isPressed()
    {
        return pressed;
    }

    void Update()
    {
        CControls@ controls = getControls();

        if (controls.isKeyJustPressed(KEY_LBUTTON) && ui.canClick(component))
        {
            pressed = true;
            component.DispatchEvent("press");
        }

        if (!controls.isKeyPressed(KEY_LBUTTON) && pressed)
        {
            if (ui.canClick(component))
            {
                component.DispatchEvent("click");
            }

            pressed = false;
            component.DispatchEvent("release");
        }
    }
}
