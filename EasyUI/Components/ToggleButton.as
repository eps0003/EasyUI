interface Toggle : Button
{
    void SetChecked(bool checked);
    bool isChecked();
}

class ToggleClickHandler : EventHandler
{
    private Toggle@ toggle;

    ToggleClickHandler(Toggle@ toggle)
    {
        @this.toggle = toggle;
    }

    void Handle()
    {
        toggle.SetChecked(!toggle.isChecked());
    }
}

class StandardToggle : Toggle
{
    private EasyUI@ ui;

    private Button@ button;

    private bool checked = false;

    StandardToggle()
    {
        error("Initialized StandardToggle using the default constructor. Use StandardToggle(EasyUI@ ui) instead.");
        printTrace();

        @ui = EasyUI();
        @button = StandardButton(ui);
        button.AddEventListener("click", ToggleClickHandler(this));
    }

    StandardToggle(EasyUI@ ui)
    {
        @this.ui = ui;
        @button = StandardButton(ui);
        button.AddEventListener("click", ToggleClickHandler(this));
    }

    void SetComponent(Component@ component)
    {
        button.SetComponent(component);
    }

    Component@ getComponent()
    {
        return button.getComponent();
    }

    void SetParent(Component@ parent)
    {
        button.SetParent(parent);
    }

    bool isPressed()
    {
        return ui.isInteractingWith(this);
    }

    void SetMargin(float x, float y)
    {
        button.SetMargin(x, y);
    }

    Vec2f getMargin()
    {
        return button.getMargin();
    }

    void SetPadding(float x, float y)
    {
        button.SetPadding(x, y);
    }

    Vec2f getPadding()
    {
        return button.getPadding();
    }

    void SetAlignment(float x, float y)
    {
        button.SetAlignment(x, y);
    }

    Vec2f getAlignment()
    {
        return button.getAlignment();
    }

    void SetMinSize(float width, float height)
    {
        button.SetMinSize(width, height);
    }

    Vec2f getMinSize()
    {
        return button.getMinSize();
    }

    void SetMaxSize(float width, float height)
    {
        button.SetMaxSize(width, height);
    }

    Vec2f getMaxSize()
    {
        return button.getMaxSize();
    }

    void SetStretchRatio(float x, float y)
    {
        button.SetStretchRatio(x, y);
    }

    Vec2f getStretchRatio()
    {
        return button.getStretchRatio();
    }

    void SetPosition(float x, float y)
    {
        button.SetPosition(x, y);
    }

    Vec2f getPosition()
    {
        return button.getPosition();
    }

    Vec2f getTruePosition()
    {
        return button.getTruePosition();
    }

    Vec2f getInnerPosition()
    {
        return button.getInnerPosition();
    }

    Vec2f getMinBounds()
    {
        return button.getMinBounds();
    }

    Vec2f getBounds()
    {
        return button.getBounds();
    }

    Vec2f getTrueBounds()
    {
        return button.getTrueBounds();
    }

    Vec2f getInnerBounds()
    {
        return button.getInnerBounds();
    }

    void CalculateBounds()
    {
        button.CalculateBounds();
    }

    bool isHovering()
    {
        return button.isHovering();
    }

    bool canClick()
    {
        return button.canClick();
    }

    bool canScroll()
    {
        return button.canScroll();
    }

    Component@[] getComponents()
    {
        return button.getComponents();
    }

    void SetChecked(bool checked)
    {
        if (this.checked == checked) return;

        this.checked = checked;

        DispatchEvent("change");
    }

    bool isChecked()
    {
        return checked;
    }

    void AddEventListener(string type, EventHandler@ handler)
    {
        button.AddEventListener(type, handler);
    }

    void RemoveEventListener(string type, EventHandler@ handler)
    {
        button.RemoveEventListener(type, handler);
    }

    void DispatchEvent(string type)
    {
        button.DispatchEvent(type);
    }

    void Update()
    {
        button.Update();
    }

    void Render()
    {
        Vec2f min = getTruePosition();
        Vec2f max = min + getTrueBounds();
        Vec2f innerBounds = getInnerBounds();

        if (ui.canClick(this))
        {
            if (isPressed())
            {
                if (isChecked())
                {
                    GUI::DrawButtonPressed(min, max);
                }
                else
                {
                    GUI::DrawButtonPressed(min, max);
                }
            }
            else
            {
                if (isChecked())
                {
                    GUI::DrawSunkenPane(min, max);
                }
                else
                {
                    GUI::DrawButtonHover(min, max);
                }
            }
        }
        else
        {
            if (isPressed())
            {
                if (isChecked())
                {
                    GUI::DrawSunkenPane(min, max);
                }
                else
                {
                    GUI::DrawButtonHover(min, max);
                }
            }
            else
            {
                if (isChecked())
                {
                    GUI::DrawButtonPressed(min, max);
                }
                else
                {
                    GUI::DrawButton(min, max);
                }
            }
        }

        Component@ component = getComponent();
        if (component !is null)
        {
            Vec2f padding = getPadding();
            Vec2f alignment = getAlignment();

            Vec2f childBounds = component.getBounds();
            Vec2f boundsDiff = innerBounds - childBounds;

            Vec2f childPos;
            childPos.x = min.x + padding.x + boundsDiff.x * alignment.x;
            childPos.y = min.y + padding.y + boundsDiff.y * alignment.y;

            component.SetPosition(childPos.x, childPos.y);
            component.Render();
        }
    }
}
