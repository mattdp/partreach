-- one-time data migration

-- create tag_groups from existing tags
INSERT INTO tag_groups (group_name, exclusive, created_at, updated_at)
SELECT DISTINCT family, exclusive, now(), now() FROM tags;

-- set FK in tags
UPDATE tags
SET tag_group_id = tag_groups.id, updated_at = now()
FROM tag_groups WHERE group_name = family;

-- make all of these tag groups applicable to Suppliers
INSERT INTO taggables (type_name, tag_group_id, created_at, updated_at)
SELECT 'Supplier', id, now(), now() FROM tag_groups;
