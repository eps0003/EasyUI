interface Progress : VisibleComponent
{
    void SetSize(float width, float height);
    void SetText(string text);
    void SetProgress(float progress);
}

class StandardProgress : Progress
{
    private string text;
    private float progress = 0;
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

    Vec2f getSize()
    {
        return size;
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

    void Render()
    {
        GUI::DrawProgressBar(position, position + size, progress);
        GUI::DrawTextCentered(text, position + size * 0.5f, color_white);
    }
}
