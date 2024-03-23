interface Label : Stack
{
    void SetText(string text);
    string getText();

    void SetFont(string font);
    string getFont();

    void SetColor(SColor color);
    SColor getColor();

    void SetWrap(bool wrap);
    bool getWrap();
}

class StandardLabel : Label, StandardStack
{
    private string text = "";
    private string font = "menu";
    private SColor color = color_white;
    private bool wrap = false;

    private string[] lines;
    private float fontHeight = 0.0f;

    StandardLabel()
    {
        super();

        UpdateFontHeight();
    }

    private void UpdateFontHeight()
    {
        Vec2f dim;
        GUI::SetFont(font);
        GUI::GetTextDimensions("", dim);
        fontHeight = dim.y;
    }

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
        UpdateFontHeight();
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

    void SetWrap(bool wrap)
    {
        if (this.wrap == wrap) return;

        this.wrap = wrap;

        DispatchEvent(Event::Wrap);
    }

    bool getWrap()
    {
        return wrap;
    }

    Vec2f getMinBounds()
    {
        if (calculateMinBounds)
        {
            // This will set calculateMinBounds back to false
            Vec2f stackMinBounds = StandardStack::getMinBounds();

            if (wrap && minSize.x > 0.0f)
            {
                lines.clear();

                // Wrap using the standard stack bounds
                float trueMinWidth = stackMinBounds.x - margin.x * 2.0f;
                float trueMinHeight = calculateTextHeight(text, font, trueMinWidth, lines);
                float minHeight = trueMinHeight + margin.y * 2.0f;

                minBounds.x = stackMinBounds.x;
                minBounds.y = Maths::Max(stackMinBounds.y, minHeight);
            }
            else
            {
                // Get dimensions for the line of text
                Vec2f labelBounds;
                GUI::SetFont(font);
                GUI::GetTextDimensions(text, labelBounds);

                // Add margin
                labelBounds += margin * 2.0f;

                // Pick the larger bounds
                minBounds.x = Maths::Max(stackMinBounds.x, wrap ? 0.0f : labelBounds.x);
                minBounds.y = Maths::Max(stackMinBounds.y, labelBounds.y);
            }
        }

        return minBounds;
    }

    Vec2f getBounds()
    {
        if (calculateBounds)
        {
            // This will set calculateBounds back to false
            bounds = StandardStack::getBounds();

            lines.clear();
            calculateTextHeight(text, font, getTrueBounds().x, lines);
        }

        return bounds;
    }

    private bool canRender()
    {
        return text != "" && (!wrap || minSize.x > 0.0f);
    }

    void Render()
    {
        if (canRender())
        {
            // The hardcoded offset correctly aligns the text within the bounds
            // May only be applicable with the default KAG font?
            Vec2f position = getTruePosition() - Vec2f(2, 2);

            GUI::SetFont(font);

            // A custom line wrapping implementation is used because of an engine bug:
            // https://github.com/transhumandesign/kag-base/issues/1964
            for (uint i = 0; i < lines.size(); i++)
            {
                GUI::DrawText(lines[i], position + Vec2f(0.0f, fontHeight * i), color);
            }
        }

        StandardStack::Render();
    }
}
