const getCommon = () => {
    return getComputedStyle(document.documentElement);
};
window.web_common = {
    getCommon: getCommon,
    CSSStyleDeclaration: CSSStyleDeclaration,
};