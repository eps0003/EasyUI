interface Progress : Component
{
    void SetSize(float width, float height);
    void SetText(string text);
    void SetProgress(float progress);
}

class StandardProgress : Progress
{
    private string text;
    private float progress = 0.0f;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;

    void SetText(string text)
    {
        this.text = text;
    }

    void SetProgress(float progress)
    {
        this.progress = Maths::Clamp01(progress);
    }

    void SetSize(float width, float height)
    {
        size.x = width;
        size.y = height;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getBounds()
    {
        return size;
    }

    private bool isHovered()
    {
        return isMouseInBounds(position, position + size);
    }

    Component@ getHoveredComponent()
    {
        return isHovered() ? cast<Component>(this) : null;
    }

    void Update()
    {

    }

    void Render()
    {
        GUI::DrawProgressBar(position, position + size, progress);
        GUI::DrawTextCentered(text, position + size * 0.5f, color_white);
    }
}
