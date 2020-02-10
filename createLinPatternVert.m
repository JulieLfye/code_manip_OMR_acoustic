function[finalmatrix] = createLinPatternVert(bwsegments, white, black, screenXpix, screenYpix)

ylim = pi * bwsegments;
[X, ~] = meshgrid(0 : ylim/(screenXpix - 1) : ylim, zeros(1, screenYpix));
linpatternimage = ((1 + sign(sin(X) + eps)) / 2) * (white - black) + black;
finalmatrix = linpatternimage ;
%finalmatrix = imgaussfilt(finalmatrix,3);

end