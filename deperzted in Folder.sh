bash << 'EOF'
PINK='\033[1;35m'
GREEN='\033[1;32m'
NC='\033[0m'
DUMP_FILE="/storage/emulated/0/Download/dumped.txt"
OUTPUT_FILE="/storage/emulated/0/Download/output.txt"
EXCLUDED_FILE="/storage/emulated/0/Download/excluded_classes.txt"

EXCLUDE_CLASSES=(
    "Button" "Toggle" "Slider" "InputField" "Text" "Image" "Canvas"
    "CanvasGroup" "Dropdown" "ScrollRect" "GraphicRaycaster"
    "EventSystem" "RawImage" "Mask"
    "Animator" "Animation" "AnimationClip" "AnimationState"
    "AnimatorController" "AnimatorOverrideController" "Avatar" "AvatarMask"
    "GameManager" "SceneManager" "PlayerPrefs" "Application"
    "Inventory" "Item" "Collectible" "CurrencyManager"
    "Terrain" "TerrainData"
    "AudioSource" "AudioListener" "AudioClip"
    "NetworkManager" "NetworkIdentity"
    "Notification" "NotificationServices"
    "RemoteNotification" "LocalNotification"
    "MessageBox" "Toast"
    "PopupWindow" "AlertDialog"
    "NotificationCenter"
    "PushwooshException"
    "Pushwoosh"
    "PushNotificationsWindows"
    "PushNotificationsIOS"
    "PushNotificationsAndroid"
    "NotificationSettings"
)

if [ ! -f "$DUMP_FILE" ]; then
    echo -e "${PINK}==============================================${NC}"
    echo -e "${PINK}          ERROR: FILE NOT FOUND!              ${NC}"
    echo -e "${PINK}==============================================${NC}"
    exit 1
fi

{
    echo "Found Namespaces and Classes with Fields:"
    echo "-------------------------------------------"

    awk -v exclude_classes="${EXCLUDE_CLASSES[*]}" '
        BEGIN {
            split(exclude_classes, excludeArray, " ");
            for (i in excludeArray) {
                excludeMap[excludeArray[i]] = 1;
            }
        }
        /\/\/ Namespace:/ && /class/ { 
            currentClass = $3; 
            if (!(currentClass in excludeMap)) {
                print; 
                inClass = 1; 
                outputFile = 1;
            } else {
                print >> excludedFile;
                inClass = 0; 
                outputFile = 0;
            }
            next 
        }
        /public class/ { 
            currentClass = $3; 
            if (!(currentClass in excludeMap)) {
                print; 
                inClass = 1; 
                outputFile = 1;
            } else {
                print >> excludedFile;
                inClass = 0; 
                outputFile = 0;
            }
            next 
        }
        inClass && /\/\/ Fields/ { print; inFields = 1; next }
        inFields && !/\/\/ Methods/ && !/^}/ { 
            if (outputFile) print; 
            else print >> excludedFile;
        }
        /\/\/ Methods/ { inFields = 0; }
        /^}/ { 
            if (outputFile) {
                print; # Print closing brace only for relevant classes
            } else {
                print >> excludedFile;
            }
            inClass = 0; 
        }
    ' excludedFile="$EXCLUDED_FILE" "$DUMP_FILE"

} > "$OUTPUT_FILE"

echo ""
echo -e "${GREEN}Output has been saved to '$OUTPUT_FILE'.${NC}"
echo -e "${GREEN}Excluded classes have been saved to '$EXCLUDED_FILE'.${NC}"

# Create Organized Dump folder and move files
mkdir -p "/storage/emulated/0/Download/Organized Dump/"
mv "$OUTPUT_FILE" "/storage/emulated/0/Download/Organized Dump/"
mv "$EXCLUDED_FILE" "/storage/emulated/0/Download/Organized Dump/"
EOF