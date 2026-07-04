# angeldelico.github.io

Personal GitHub Pages site. Contains a **Buy List** system at `buylist/`.

## Buy List workflow (IMPORTANT)

When the user sends a photo of a product they want to buy (possibly with a note
about where to buy it, price, etc.), do the following:

1. Save the image into `buylist/images/` with a short descriptive kebab-case
   filename (e.g. `stitch-kitten-plush.png`). If the user pasted the image in
   chat, copy it from the message attachment path into that folder.
2. Add an entry to the `items` array in `buylist/data.json`:

   ```json
   {
     "id": "item-YYYYMMDD-shortname",
     "name": "Product name (infer from the photo if not given)",
     "place": "Where to buy — store name / mall / website",
     "price": "optional, keep the currency the user used",
     "notes": "optional extra details",
     "image": "images/<filename>",
     "status": "to-buy",
     "added": "YYYY-MM-DD"
   }
   ```

3. Commit and push to the branch the session designates (or `master` if the
   user says to publish directly). The list is visible at
   https://angeldelico.github.io/buylist/

Other operations the user may ask for:

- **"I bought X"** → set that item's `status` to `"bought"`.
- **Remove/edit an item** → update `data.json` accordingly; delete the image
  file too if the item is removed.
- **Pop-up store info** (a store, market, or event that exists only for a
  limited time) → add to the `popupStores` array:

  ```json
  {
    "id": "popup-YYYYMMDD-shortname",
    "name": "Store/event name",
    "location": "Address or venue (used for the Google Maps link)",
    "start": "YYYY-MM-DD",
    "end": "YYYY-MM-DD",
    "notes": "optional",
    "image": "images/<filename> or empty string"
  }
  ```

  The page automatically labels each pop-up as Upcoming / Now open / Ended
  based on today's date.

Notes:

- `buylist/data.json` currently contains one sample item and one sample
  pop-up store. Delete them when adding the first real entry.
- `buylist/index.html` is a static page that fetches `data.json`; no build
  step is needed.
- Site pages use inline styles, Avenir fonts, and color `#464646`.
