interface Avatar : Stack
{
    void SetPlayer(CPlayer@ player);
    CPlayer@ getPlayer();
}

class StandardAvatar : Avatar, StandardStack
{
    private CPlayer@ player;

    void SetPlayer(CPlayer@ player)
    {
        if (this.player is player) return;

        @this.player = player;

        DispatchEvent(Event::Player);
    }

    CPlayer@ getPlayer()
    {
        return player;
    }

    bool canClick()
    {
        return true;
    }

    void Render()
    {
        if (!isVisible()) return;

        Vec2f position = getTruePosition();
        Vec2f bounds = getTrueBounds();

        GUI::DrawRectangle(position, position + bounds, color_black);

        if (player !is null)
        {
            float scale = Maths::Min(bounds.x, bounds.y);
            Vec2f offset = Vec2f(bounds.x - scale, bounds.y - scale) * 0.5f;

            player.drawAvatar(position + offset, scale / 96.0f);
        }

        StandardStack::Render();
    }
}
