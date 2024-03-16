interface Label : Stack
{
    void SetText(string text);
    string getText();

    void SetFont(string font);
    string getFont();

    void SetColor(SColor color);
    SColor getColor();
}

class StandardLabel : Label, StandardStack
{
    private string text = "";
    private string font = "menu";
    private SColor color = color_white;

    void SetText(string text)
    {
        if (this.text == text) return;

        this.text = text;

        DispatchEvent(Event::Text);
        CalculateMinBounds();
    }

    string getText()
    {
        return text;
    }

    void SetFont(string font)
    {
        if (this.font == font) return;

        this.font = font;

        DispatchEvent(Event::Font);
        CalculateMinBounds();
    }

    string getFont()
    {
        return font;
    }

    void SetColor(SColor color)
    {
        if (this.color == color) return;

        this.color = color;

        DispatchEvent(Event::Color);
    }

    SColor getColor()
    {
        return color;
    }

    void SetMaxSize(float width, float height)
    {
        width = Maths::Max(0, width);
        height = Maths::Max(0, height);

        if (maxSize.x == width && maxSize.y == height) return;

        maxSize.x = width;
        maxSize.y = height;

        DispatchEvent(Event::MaxSize);
        CalculateMinBounds();
    }

    void SetStretchRatio(float x, float y)
    {
        x = Maths::Clamp01(x);
        y = Maths::Clamp01(y);

        if (stretchRatio.x == x && stretchRatio.y == y) return;

        stretchRatio.x = x;
        stretchRatio.y = y;

        DispatchEvent(Event::StretchRatio);
        CalculateMinBounds();
    }

    Vec2f getMinBounds()
    {
        if (calculateMinBounds)
        {
            // This will set calculateMinBounds back to false
            Vec2f stackMinBounds = StandardStack::getMinBounds();

            // Get dimensions for the line of text
            Vec2f labelBounds;
            GUI::SetFont(font);
            GUI::GetTextDimensions(text, labelBounds);

            if (maxSize.x != 0.0f && labelBounds.x > maxSize.x)
            {
                labelBounds.x = maxSize.x;
                labelBounds.y = calculateTextHeight(text, font, labelBounds.x);
            }
            else if (stretchRatio.x != 0.0f)
            {
                parent.CalculateMinBounds();

                // Stretch to fill the parent or the screen
                Vec2f stretchBounds = parent !is null
                    ? parent.getStretchBounds(this)
                    : getDriver().getScreenDimensions();
                stretchBounds *= stretchRatio;

                // Constrain the stretch bounds within the maximum size if configured
                float maxBoundsX = maxSize.x != 0.0f
                    ? Maths::Min(stretchBounds.x, maxSize.x + margin.x * 2.0f)
                    : stretchBounds.x;
                maxBoundsX -= margin.x * 2.0f;

                labelBounds.x = maxBoundsX;
                labelBounds.y = calculateTextHeight(text, font, labelBounds.x);
            }

            labelBounds += margin * 2.0f;

            // Pick the larger bounds
            minBounds.x = Maths::Max(stackMinBounds.x, labelBounds.x);
            minBounds.y = Maths::Max(stackMinBounds.y, labelBounds.y);
        }

        return minBounds;
    }

    void Render()
    {
        if (text != "")
        {
            // The magic values correctly align the text within the bounds
            // May only be applicable with the default KAG font?
            Vec2f position = getTruePosition() - Vec2f(2, 2);
            Vec2f bounds = getTrueBounds();

            GUI::SetFont(font);
            GUI::DrawText(text, position, position + bounds, color, false, false);
        }

        StandardStack::Render();
    }
}
