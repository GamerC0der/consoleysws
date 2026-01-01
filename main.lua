function love.load()
    love.graphics.setBackgroundColor(0,0,0)
    vertices={{1,1,1},{1,1,-1},{1,-1,1},{1,-1,-1},{-1,1,1},{-1,1,-1},{-1,-1,1},{-1,-1,-1}}
    faces={
        {1,2,4,3}, {5,6,8,7}, {2,6,8,4},
        {5,1,3,7}, {5,6,2,1}, {7,8,4,3}
    }
    edges={{1,2},{1,3},{1,5},{2,4},{2,6},{3,4},{3,7},{4,8},{5,6},{5,7},{6,8},{7,8}}
    angle=0
end

function love.update(dt) angle=angle+dt end

function love.draw()
    local p={}
    local ay,ax=math.pi/4,math.atan(1/math.sqrt(2))
    for i,v in ipairs(vertices) do
        local x,y,z=v[1],v[2],v[3]
        local rx=x*math.cos(angle)-z*math.sin(angle)
        local rz=x*math.sin(angle)+z*math.cos(angle)
        local ry=y*math.cos(ax)-rz*math.sin(ax)
        local rrz=y*math.sin(ax)+rz*math.cos(ax)
        local rrx=rx*math.cos(ay)-rrz*math.sin(ay)
        p[i]={400+rrx*60,300-ry*60}
    end
    love.graphics.setColor(0,1,1)
    for _,f in ipairs(faces) do
        local poly={}
        for _,vi in ipairs(f) do
            local v=p[vi]
            table.insert(poly,v[1])
            table.insert(poly,v[2])
        end
        love.graphics.polygon("fill",poly)
    end

    love.graphics.setColor(0,0,0.5)
    for _,e in ipairs(edges) do
        local v1,v2=p[e[1]],p[e[2]]
        love.graphics.line(v1[1],v1[2],v2[1],v2[2])
    end
end
