{% docs stg_chinook__artists %}
Artists dimension table cleaned and standardized from the raw Artist source.

**Key Fields:**
- `artist_id`: Unique identifier for each artist
- `name`: Artist/band name (cleaned and trimmed)

**Transformation Logic:**
1. Convert ArtistId to integer
2. Trim whitespace from Name
3. Add loaded_at timestamp
{% enddocs %}
