use rusqlite::{Connection, Result, ffi};
use rusqlite::functions::{FunctionFlags, Context};
use skim::fuzzy_matcher::FuzzyMatcher;
use skim::fuzzy_matcher::skim::SkimMatcherV2;
// use rusqlite::types::{ToSqlOutput, Value};
use std::os::raw::{c_char, c_int};

// The main entry point for the SQLite extension

#[unsafe(no_mangle)]
pub unsafe extern "C" fn sqlite3_extension_init(
    db: *mut ffi::sqlite3,
    pz_err_msg: *mut *mut c_char,
    p_api: *mut ffi::sqlite3_api_routines,
) -> c_int {
    unsafe {
        Connection::extension_init2(db, pz_err_msg, p_api, extension_init)
    }
}


fn extension_init(db: Connection) -> Result<bool> {
    db.create_scalar_function(
        "skim_score",
        2,
        FunctionFlags::SQLITE_UTF8 | FunctionFlags::SQLITE_DETERMINISTIC,
        skim_score,
    )?;
    // rusqlite::trace::log(ffi::SQLITE_WARNING, "Rusqlite extension initialized");
    Ok(false)
}


fn skim_score(ctx: &Context) -> Result<i64> {
    let query = ctx.get::<String>(0)?;
    let choice = ctx.get::<String>(1)?;

    let matcher = SkimMatcherV2::default();
    let score = matcher.fuzzy_match(&choice, &query).unwrap_or(0);

    Ok(score)
}
