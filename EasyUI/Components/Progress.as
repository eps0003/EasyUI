interface Progress : Stack
{
    void SetProgress(float progress);
    float getProgress();
}

class StandardProgress : Progress, StandardStack
{
    private float progress = 0.0f;

    void SetProgress(float progress)
    {
        progress = Maths::Clamp01(progress);

        if (this.progress == progress) return;

        this.progress = progress;

        DispatchEvent("change");
    }

    float getProgress()
    {
        return progress;
    }

    bool canClick()
    {
        return true;
    }

    void Render()
    {
        Vec2f min = getTruePosition();
        Vec2f max = min + getTrueBounds();
        Vec2f innerBounds = getInnerBounds();

        GUI::DrawProgressBar(min, max, progress);

        StandardStack::Render();
    }
}
