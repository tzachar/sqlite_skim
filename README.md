# `sqlite_skim` - SQLite Fuzzy Matching Extension

`sqlite_skim` is a Rust-based SQLite loadable extension that provides a fuzzy matching scoring function, `skim_score`, powered by the `skim-rs` library.
This allows you to integrate powerful fuzzy string matching into your SQL queries, enabling features like search ranking and intelligent sorting of results.

## Features

- `skim_score(query_string, choice_string)`: Returns an integer score representing how well `choice_string` matches `query_string` using the `skim-rs` fuzzy matching algorithm.

## Requirements

- [Rustup](https://rustup.rs/) (for managing Rust toolchains)
- Rust `nightly` toolchain
- SQLite

## Building

To build the `sqlite_skim` extension, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/sqlite_skim.git
    cd sqlite_skim/sqlite_skim
    ```
    (Replace `https://github.com/your-repo/sqlite_skim.git` with the actual repository URL once available)

2.  **Set the Rust toolchain to nightly:**
    This project requires the nightly Rust toolchain due to dependencies within `skim-rs`.
    ```bash
    rustup override set nightly-2026-02-11
    ```

3.  **Build in release mode:**
    ```bash
    cargo build --release
    ```

    This will produce the loadable SQLite extension library. The path to the library will typically be:
    -   Linux: `target/release/libsqlite_skim.so`
    -   macOS: `target/release/libsqlite_skim.dylib`
    -   Windows: `target/release/sqlite_skim.dll`

## Usage

Once the extension library is built, you can load it into your SQLite environment and start using the `skim_score` function.

1.  **Load the extension in SQLite:**

    Open the SQLite CLI or integrate into your application's SQLite connection:

    ```sql
    SELECT load_extension('/path/to/your/sqlite_skim/target/release/libsqlite_skim.so');
    ```
    Replace `/path/to/your/sqlite_skim/target/release/libsqlite_skim.so` with the actual absolute path to the compiled library file.

2.  **Using the `skim_score` function:**

    The `skim_score` function takes two string arguments: the `query_string` and the `choice_string`.

    ```sql
    SELECT skim_score('query', 'choice string');
    ```

    **Examples:**
    ```sql
    -- Basic fuzzy matching
    SELECT skim_score('apple', 'I like apples');
    SELECT skim_score('data', 'database management');
    SELECT skim_score('db', 'database');

    -- No match will return 0
    SELECT skim_score('xyz', 'abc');
    ```

3.  **Sorting results with `skim_score`:**

    You can use `skim_score` in your `ORDER BY` clause to sort results based on their relevance to a query.

    Imagine a table `products` with a `name` column:

    ```sql
    CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT);
    INSERT INTO products (name) VALUES
        ('Apple MacBook Pro'),
        ('Banana Smoothie Maker'),
        ('Red Delicious Apples'),
        ('Pineapple Slicer');

    SELECT
        name,
        skim_score('apple', name) AS score
    FROM
        products
    ORDER BY
        score DESC;
    ```

    This query would return products related to 'apple', with the most relevant (highest score) first.

