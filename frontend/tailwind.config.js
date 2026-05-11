/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: "#00CEA6",
          dark: "#00A987",
          soft: "#DDF9F3"
        },
        ink: "#172033",
        muted: "#667085",
        line: "#E4E8EF",
        page: "#F5F7FB",
        amber: "#FFC100",
        coral: "#EF5B5B"
      },
      boxShadow: {
        card: "0 24px 70px rgba(23, 32, 51, 0.10)",
        soft: "0 14px 35px rgba(0, 206, 166, 0.22)"
      }
    }
  },
  plugins: []
};
