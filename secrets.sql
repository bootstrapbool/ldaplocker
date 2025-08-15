/* Secrets
*
* Fields:
*   Filepath
*       The filepath from the project root to the ldif file containing the
*       definition for the ldap entry.
*
*       Should be something like 'ldif/organizations/file.ldif'
*   DistinguishedName
*       The full distinguished name for the ldap entry to which secrets
*       correspond.
*   Expired
*       Whether or not the password/pin/security question is expired.
*   Category
*       One of 'api key', 'identifier', 'password', 'pin', 'security question',
*       or 'misc'.
*   Description
*       Any additional explanation of what the secret is (beyond the category)
*       should be set here.
*
*       If the Category is 'security question', the question to which the
*       secret answers should be set here.
*   Secret
*       GPG encrypted secret.
*/

CREATE TABLE Secrets (
    Id                  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    Filepath            TEXT    NOT NULL,
    DistinguishedName   TEXT    NOT NULL,
    Expired             BOOLEAN NOT NULL,
    Category            TEXT    NOT NULL,
    Description         TEXT    NOT NULL,
    Secret              TEXT    NOT NULL
)
