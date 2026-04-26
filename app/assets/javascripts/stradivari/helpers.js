window.Stradivari = window.Stradivari || {};

Object.assign(window.Stradivari, {
  all(selector, root = document) {
    return Array.from(root.querySelectorAll(selector));
  },

  delegate(root, eventName, selector, handler) {
    root.addEventListener(eventName, (event) => {
      const target = event.target.closest(selector);

      if (target && root.contains(target)) {
        handler.call(target, event, target);
      }
    });
  },

  emit(element, eventName, detail = {}) {
    element.dispatchEvent(new CustomEvent(eventName, { bubbles: true, detail }));
  },

  ready(callback) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', callback, { once: true });
    } else {
      callback();
    }
  },

  selectorEscape(value) {
    if (window.CSS && window.CSS.escape) {
      return window.CSS.escape(value);
    }

    return String(value).replace(/[^a-zA-Z0-9_-]/g, '\\$&');
  }
});

window._TABLE_ = (() => {
  const query = () => {
    const search = window.location.search.substring(1);
    return search ? window.decodeURI(search).split('&') : [];
  };

  const navigate = (params) => window.location.assign(params.length > 0 ? `?${params.join('&')}` : window.location.pathname);

  const decodeURIComponentAndSpaces = (value) => window.decodeURIComponent(value.replace(/\+/g, ' '));

  return {
    filterURLParameters(callback) {
      return navigate(query().filter(callback));
    },

    mergeURLParameters(params) {
      const parameterNames = params.map((param) => param.split('=')[0]);

      return navigate(
        query()
          .filter((param) => !parameterNames.includes(param.split('=')[0]))
          .concat(params)
      );
    },

    parseURLParameters(uri) {
      const matcher = /([^&=]+)=?([^&|#]*)/g;
      const queryString = uri.split('?')[1];
      const params = {};

      if (queryString) {
        let entry = matcher.exec(queryString);

        while (entry) {
          let key = decodeURIComponentAndSpaces(entry[1]);
          const value = decodeURIComponentAndSpaces(entry[2]);

          if (key.substring(key.length - 2) === '[]') {
            key = key.substring(0, key.length - 2);
            params[key] = params[key] || [];
            params[key].push(value);
          } else {
            params[key] = value;
          }

          entry = matcher.exec(queryString);
        }
      }

      return params;
    }
  };
})();