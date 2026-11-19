"""Geometry of the helmet above the hazard collar and the visible figure silhouette."""
import cv2
import numpy as np


def shape(cell, nominal, height, sample, gun_mask=None):
    alpha = (cell[:, :, 3] >= 128).astype(np.uint8)
    _, ids, stats, _ = cv2.connectedComponentsWithStats(alpha, connectivity=8)
    body = ids == (1 + stats[1:, cv2.CC_STAT_AREA].argmax())
    y, x = np.indices(body.shape)
    cx, cy, _ = sample
    crown = int(y[body & (abs(x-cx) <= round(nominal*.13)) & (y <= cy)].min())
    cap = body & (y < crown + height*.20) & (y >= crown) & (abs(x-cx) < nominal*.24)
    mid = np.median(x[cap])
    # Orange stripes, restricted to the neck below the cap. A stripe occupies
    # several contiguous columns; bolts and isolated rust highlights do not.
    r, g, b = cell[:, :, :3].astype(np.int16).transpose(2, 0, 1)
    band = ((r > 130) & (r-g > 85) & (g-b > 22) & body &
            (abs(x-mid) <= height*.17) & (y > crown+height*.26) & (y < crown+height*.75))
    _, groups, components, _ = cv2.connectedComponentsWithStats(band.astype('uint8'))
    stripe = np.zeros_like(body)
    for label, (_, _, w, h, area) in enumerate(components[1:], 1):
        if area >= max(4, height**2*.0006) and w >= 3 and h >= 2:
            stripe |= groups == label
    # Follow the upper edge of the central stripes. At the sides the collar
    # curves up and overlaps the helmet, so use its central third.
    centre = stripe & (abs(x-mid) <= height*.10)
    columns = centre.any(axis=0)
    helmet_h = None
    if columns.sum() >= max(3, height*.025):
        upper = np.argmax(centre[:, columns], axis=0)
        helmet_h = int(round(np.median(upper))) - crown
    # Without an annotated gun mask the connected silhouette includes attached
    # equipment. Preserve that limitation instead of classifying dark ink as gun.
    visible = body & (y >= crown) & (y < crown+height)
    if gun_mask is not None:
        visible &= ~gun_mask
    xx = x[visible]
    lab = cv2.cvtColor(cell[:, :, :3].astype(np.float32)/255, cv2.COLOR_RGB2Lab)
    return dict(helmet_ratio=round(helmet_h/height, 4) if helmet_h else None,
                width_ratio=round((int(xx.max())-int(xx.min())+1)/height, 4),
                mean_l=round(float(lab[:, :, 0][visible].mean()), 2),
                mean_c=round(float(np.hypot(lab[:, :, 1], lab[:, :, 2])[visible].mean()), 2))
