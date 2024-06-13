BEGIN;

-- Base table for imports storing import ids and types
CREATE TABLE IF NOT EXISTS bookbrainz.import (
    id SERIAL PRIMARY KEY,
    type bookbrainz.entity_type NOT NULL
);

-- Tables linking import and relevant data in entitytype_data tables
CREATE TABLE IF NOT EXISTS bookbrainz.author_import_header (
    import_id INT PRIMARY KEY,
    data_id INT NOT NULL
);
ALTER TABLE bookbrainz.author_import_header ADD FOREIGN KEY (import_id) REFERENCES bookbrainz.import (id);
ALTER TABLE bookbrainz.author_import_header ADD FOREIGN KEY (data_id) REFERENCES bookbrainz.author_data (id);

CREATE TABLE IF NOT EXISTS bookbrainz.edition_import_header (
    import_id INT PRIMARY KEY,
    data_id INT NOT NULL
);
ALTER TABLE bookbrainz.edition_import_header ADD FOREIGN KEY (import_id) REFERENCES bookbrainz.import (id);
ALTER TABLE bookbrainz.edition_import_header ADD FOREIGN KEY (data_id) REFERENCES bookbrainz.edition_data (id);

CREATE TABLE IF NOT EXISTS bookbrainz.edition_group_import_header (
    import_id INT PRIMARY KEY,
    data_id INT NOT NULL
);
ALTER TABLE bookbrainz.edition_group_import_header ADD FOREIGN KEY (import_id) REFERENCES bookbrainz.import (id);
ALTER TABLE bookbrainz.edition_group_import_header ADD FOREIGN KEY (data_id) REFERENCES bookbrainz.edition_group_data (id);

CREATE TABLE IF NOT EXISTS bookbrainz.publisher_import_header (
    import_id INT PRIMARY KEY,
    data_id INT NOT NULL
);
ALTER TABLE bookbrainz.publisher_import_header ADD FOREIGN KEY (import_id) REFERENCES bookbrainz.import (id);
ALTER TABLE bookbrainz.publisher_import_header ADD FOREIGN KEY (data_id) REFERENCES bookbrainz.publisher_data (id);

CREATE TABLE IF NOT EXISTS bookbrainz.series_import_header (
    import_id INT PRIMARY KEY,
    data_id INT NOT NULL
);
ALTER TABLE bookbrainz.series_import_header ADD FOREIGN KEY (import_id) REFERENCES bookbrainz.import (id);
ALTER TABLE bookbrainz.series_import_header ADD FOREIGN KEY (data_id) REFERENCES bookbrainz.series_data (id);

CREATE TABLE IF NOT EXISTS bookbrainz.work_import_header (
    import_id INT PRIMARY KEY,
    data_id INT NOT NULL
);
ALTER TABLE bookbrainz.work_import_header ADD FOREIGN KEY (import_id) REFERENCES bookbrainz.import (id);
ALTER TABLE bookbrainz.work_import_header ADD FOREIGN KEY (data_id) REFERENCES bookbrainz.work_data (id);

-- Table to store votes cast to discard an import
CREATE TABLE IF NOT EXISTS bookbrainz.discard_votes (
    import_id INT NOT NULL,
    editor_id INT NOT NULL,
    voted_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT timezone('UTC'::TEXT, now()),
    PRIMARY KEY (
        import_id,
        editor_id
    )
);
ALTER TABLE bookbrainz.discard_votes ADD FOREIGN KEY (import_id) REFERENCES bookbrainz.import (id);
ALTER TABLE bookbrainz.discard_votes ADD FOREIGN KEY (editor_id) REFERENCES bookbrainz.editor (id);

-- Table to store all origin sources of imported data
CREATE TABLE IF NOT EXISTS bookbrainz.origin_source (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL CHECK (name <> '')
);

-- Table to store source metadata linked with import and (upon it's subsequent upgrade) with entity
-- The origin_source_id refers to the source of the import, a foreign key reference to origin_import
-- The origin_id is the designated id of the import data item at it's source
CREATE TABLE IF NOT EXISTS bookbrainz.link_import (
    import_id INT,
    origin_source_id INT NOT NULL,
    origin_id TEXT NOT NULL CHECK (origin_id <> ''),
    imported_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT timezone('UTC'::TEXT, now()),
    last_edited TIMESTAMP WITHOUT TIME ZONE,
    entity_id UUID DEFAULT NULL,
    import_metadata jsonb,
    PRIMARY KEY (
        origin_source_id,
        origin_id
    )
);
ALTER TABLE bookbrainz.link_import ADD FOREIGN KEY (entity_id) REFERENCES bookbrainz.entity (bbid);
ALTER TABLE bookbrainz.link_import ADD FOREIGN KEY (import_id) REFERENCES bookbrainz.import (id);
ALTER TABLE bookbrainz.link_import ADD FOREIGN KEY (origin_source_id) REFERENCES bookbrainz.origin_source (id);

-- Imported entities views --
CREATE OR REPLACE VIEW bookbrainz.author_import AS
    SELECT
        import.id AS import_id,
        author_data.id as data_id,
        author_data.annotation_id,
        author_data.disambiguation_id,
        alias_set.default_alias_id,
        author_data.begin_year,
        author_data.begin_month,
        author_data.begin_day,
        author_data.end_year,
        author_data.end_month,
        author_data.end_day,
        author_data.begin_area_id,
        author_data.end_area_id,
        author_data.ended,
        author_data.area_id,
        author_data.gender_id,
        author_data.type_id,
        author_data.alias_set_id,
        author_data.identifier_set_id,
        import.type
    FROM bookbrainz.import import
    LEFT JOIN bookbrainz.author_import_header author_import_header ON import.id = author_import_header.import_id
    LEFT JOIN bookbrainz.author_data author_data ON author_import_header.data_id = author_data.id
    LEFT JOIN bookbrainz.alias_set alias_set ON author_data.alias_set_id = alias_set.id
    WHERE import.type = 'Author';


CREATE OR REPLACE VIEW bookbrainz.edition_import AS
    SELECT
        import.id AS import_id,
        edition_data.id as data_id,
        edition_data.disambiguation_id,
        alias_set.default_alias_id,
        edition_data.width,
        edition_data.height,
        edition_data.depth,
        edition_data.weight,
        edition_data.pages,
        edition_data.format_id,
        edition_data.status_id,
        edition_data.alias_set_id,
        edition_data.identifier_set_id,
        import.type,
        edition_data.language_set_id,
        edition_data.release_event_set_id
    FROM bookbrainz.import import
    LEFT JOIN bookbrainz.edition_import_header edition_import_header ON import.id = edition_import_header.import_id
    LEFT JOIN bookbrainz.edition_data edition_data ON edition_import_header.data_id = edition_data.id
    LEFT JOIN bookbrainz.alias_set alias_set ON edition_data.alias_set_id = alias_set.id
    WHERE import.type = 'Edition';

CREATE OR REPLACE VIEW bookbrainz.publisher_import AS
    SELECT
        import.id AS import_id,
        publisher_data.id as data_id,
        publisher_data.disambiguation_id,
        alias_set.default_alias_id,
        publisher_data.begin_year,
        publisher_data.begin_month,
        publisher_data.begin_day,
        publisher_data.end_year,
        publisher_data.end_month,
        publisher_data.end_day,
        publisher_data.ended,
        publisher_data.area_id,
        publisher_data.type_id,
        publisher_data.alias_set_id,
        publisher_data.identifier_set_id,
        import.type
    FROM
        bookbrainz.import import
        LEFT JOIN bookbrainz.publisher_import_header publisher_import_header ON import.id = publisher_import_header.import_id
        LEFT JOIN bookbrainz.publisher_data publisher_data ON publisher_import_header.data_id = publisher_data.id
        LEFT JOIN bookbrainz.alias_set alias_set ON publisher_data.alias_set_id = alias_set.id
        WHERE import.type = 'Publisher';

CREATE OR REPLACE VIEW bookbrainz.edition_group_import AS
    SELECT
        import.id AS import_id,
        edition_group_data.id as data_id,
        edition_group_data.disambiguation_id,
        alias_set.default_alias_id,
        edition_group_data.type_id,
        edition_group_data.alias_set_id,
        edition_group_data.identifier_set_id,
        import.type
    FROM bookbrainz.import import
    LEFT JOIN bookbrainz.edition_group_import_header edition_group_import_header ON import.id = edition_group_import_header.import_id
    LEFT JOIN bookbrainz.edition_group_data edition_group_data ON edition_group_import_header.data_id = edition_group_data.id
    LEFT JOIN bookbrainz.alias_set alias_set ON edition_group_data.alias_set_id = alias_set.id
    WHERE import.type = 'EditionGroup';

CREATE OR REPLACE VIEW bookbrainz.series_import AS
    SELECT
        import.id as import_id,
        series_data.id AS data_id,
        series_data.annotation_id,
        series_data.disambiguation_id,
        alias_set.default_alias_id,
        series_data.ordering_type_id,
        series_data.alias_set_id,
        series_data.identifier_set_id,
        import.type
    FROM bookbrainz.import import
    LEFT JOIN bookbrainz.series_import_header series_import_header ON import.id = series_import_header.import_id
    LEFT JOIN bookbrainz.series_data series_data ON series_import_header.data_id = series_data.id
    LEFT JOIN bookbrainz.alias_set alias_set ON series_data.alias_set_id = alias_set.id
    WHERE import.type = 'Series';

CREATE OR REPLACE VIEW bookbrainz.work_import AS
    SELECT
        import.id as import_id,
        work_data.id AS data_id,
        work_data.annotation_id,
        work_data.disambiguation_id,
        alias_set.default_alias_id,
        work_data.type_id,
        work_data.alias_set_id,
        work_data.identifier_set_id,
        import.type,
        work_data.language_set_id
    FROM bookbrainz.import import
    LEFT JOIN bookbrainz.work_import_header work_import_header ON import.id = work_import_header.import_id
    LEFT JOIN bookbrainz.work_data work_data ON work_import_header.data_id = work_data.id
    LEFT JOIN bookbrainz.alias_set alias_set ON work_data.alias_set_id = alias_set.id
    WHERE import.type = 'Work';

COMMIT;
