ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �"rY �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�l��9�eQ:�b�'�y��o�vd�'�%�U�f�E��Q�C�V}ls�eC��*�ޥ( |��v�o�/ݑUZg�܃��\����6J�Mhi�نVd�`)�j�c{U�;�����MҠ�W-C�A�!�J��RE*��J�L.�~�3 �8� ݄-�՜���PqP�-��j��tGk�KU��%�iT�����9(�č��4ي���	��=@ C��>ff�9ѯ���fw�.kǰV�c��x�#���+l��Te͞ӆڃ��
�3�kXMh!�@�����H���abږ��F"~�0��{�1M�qF`虢WS)fhQ:2�(R��k��ܞm���d��B�pC����5��1��6P���3��`N���^͐cFق���vj�|`�q�\zg�����-��#�ĜQ7�^MJ\�!W�CD���D���j�"�g�Va�怾�,�����au�V򕈧{��-]�F�hR���ԧ���o�CM�a�X1��m�E>nZ�1���(��X��'@xpJ����ϙ�V����;�m�̿p����矍�x!.ph��6��:��w���G�ݡlõ��/��$���u��1)V��*�Z9%�c>\��%����&�9����Y~���˃9�eO�'�n��[l��ˆ9�o�Jm��綡?H������a�v ��̿X4��?|t����Fk��e�Ţ}'Fa�LX�R�}P3�*$����:`�σ	ǀ�7���m��P3L��A��� ӵ�&�'��Ծ�`˅$Iv��aM9U<lMU�n����;0�y]8D���n�Nj��U:2�5z�I�bh.�����PG�VE;�Ȯ��������5C��t�>��ۮf�P��&��(�������g�^���FÉ�h;ORC�K��b��؋�e���sS9�2�D�xc������R����ii�u�&�����?���X�A�Z���_�?��Vh�:q��#;��jQ��}�!�\]W���G���|��HQ����M�B��A�ח���5y�"�=@���k\��T:�P{�n5;����� �6����]v^�NR3�RQ��d�r�u���˸���i��R!�p�Wx3�4��F���@�� �*�#桐1;�&���ar��`S ث ��a�iO�}Ƙ���s$2�Vu�#)�7���keALq��kC2 ���ѹ9蓘�L.��Xas�{��(���UR��4�ϡ�A��P���}�Aن��T0�JĲ?��~�{/s��lH��A�s7F�����:Pu<m~�~A�׈�n�9�;��xI��5 ��ׯ��Z#zC�z� !����ӡ-+T���f��Ra�����|?V�� 3�߬�뀍��ˆ9�=����gy.>-����������ų�<�q� KO�6��9fMak7k��Hs-׀��~kH�s�;������UR��au�oH7A�C�ͷ����`��� ��6&�ˡKd�f�d9�:�K�J�T|uqum6�F�Pm��6t~DF���p^¿��K`����CA͆7׉j�[���Y�X�S���R�ճj� �j՛��@�G;+�6D�մ_�ta��+x}�v������	%>�zN���߁w�����<� ����$ĸ���]PD��t�׀~��{M�R��xLttz@'�aEL���*�w�E�i�@(�$�_�"6G�+h����NΏ���j���Ǳ���[l�/���d�y��"���̴���_<��S��j�=��Pu4!�B!ӂ-���qT�@e�h�{����������q&�o�?����p�p�|�H�����N���Z`���{X���S�.*��Z`����wᆎ���� hY��#0-Uw�����7�0�w�!ؿ����U[���G��*�}S8���5��jN�g�����d>��}1Fm�R��;A�Ȩi��1 �ee���b���j;�����=�_���j`t
��z d��߃G��h!�*;�@�E~�[���B�������a�埙���&�c-���z�Q�����I�&� �9����0q��W_x0�w(�b'v�CL�3�R���ݎ�Q{����������\tJ���&�k=�����v��<�q���Y�)�k��Ƃ��f��B����:��3?b��C�5�|h�7b��������Dg�_���5���{���sE�y�����T��l2W$�Rd���J���_��Cs�r'p���N��������K84C���a;��F�!����[=���-����2�?�
�խw���P�1<�U��z'Ƣ��p����.f�(���(4�� ���2��ud4 ���n�9�#d�[���/(^�a�ϴ��l�?��	���8���u������/��s����x��^!��5QW�ޥax��&
̹�-H��T��멳�x&������K�=|� �o2���5�<�r��v �%�2���.�%r{�!�*���CI*���tY�T�Z����R�J����'��R�X�su�i�H_�"���r�џ`�|)���gy�.���R���i8��C#2�|x�;���b��3�'e.vu5�|e�����sՓ�I��\��Qo���l�KSX�e��W���J��5U���zw<��6f@�B
ض5M ��U�n4�w.�r����3o�v�%~j�}@X��wװ���>6����������G�F��G�
�;\��p����P�B��> _��z��9�� L:�d��
� /1��K|�x
�ſuxc��݊���-��r���+
h��r���&��x|Xv��s)�"��rS�����6����s��{��Ґ:��xvQX�+�-a �#�D/����Գ%�`D�<��/�!rU���؉[B�t��X��kn\�Ԝ��O����\
���g�c�/p1O�o���>_��8�9�0
�a�X�
(�j�
��+��/J_��U:��d�;�����K!�����6��z���/6�-U=��q@cL�6]��M8��%D-+��9�@�9�ٟ���qn����+��r�òQk.<`�C`Xm@�� �|�zg����Gp]�R�9#�o,��Q�r��_��,�����G��pC�C�Ol������L��2� &_Y���U Bb����E�>�27�b\d�)S��7D�]�Kh��'nnz�&������-:��o�-~���?�pwhcu�?g������_+1O=���Em,���i�O���_���|M�Q����?|���_������֟~����<��i)���	��h��N"k5��eȳ���F"�+2�	���Ǝ l��W��~EMW����7�O�ij*�_�!��t�O���m�ɷ�)*e�a9����׭��F��u�������d5�o�������y;�����?�[��������R��[�z�2�i�����0��~�kX��O=�7���O,ܕ�X]�G���_�q����-������?/�7�-���cX�o5�&J�4h� ���0�i�����=�A�\��|KV �g:���H�j{�rd��
���``<�h1J|'��v����%�sQe��NSf������D���rB���&�qmi"U��k �NCR�� %���L.%V%��^/�r��y*%*��8�%�v�,ݒ^/�6#���xW��R�܁q��<g$�;P.�<�A�fE�&%;�T�^��.�r�]�����n���j�F�+K�s���)�t���{]�e�N�<�v.�U�aT�lbxz)��o;��ۤ}Z�s��e�P��b罞����w�b����9�P�1�j�;�i�$���׏ϓ�=H���GGYi�^���4p�w�d�������i_�	�IU:.$���_����qs����X8����R��d�8��X�X腊��l�Q�Z�W�7��S4��B69�5[)�	�-eS)��@����̺;�#6۽�Tu#ߏߪ'��K�q8.W�$��|���ʵ։| d�fEU�B�4~j�;�J<g����)/����y���D����H�����~;-�X�I��#��XHٸW���[H��d�:��x2�L�׭r�;8��j����R�bR�XA�����݂h�{�f0%2m� �R��o���)��k�z��2!'"��U<�`E?��~�i��� f�o�M#cH�,��Dܭ������2�S|"�okeq�NX^*��}uu��#����W�Ǌk���O�eX�n��-��l��=�G�gF��2�6�E��Q���_��/:}�o`M�`����eYas�s-��˹:Z��tBR�R�\v���mkt2�dlC�&7���I��F�)uZ�L�}��cM�k�4T.�G:�v�ɕŲ�O�G�b�,Ժ�9uY�{)�xՀ��_�ֆGea(d4(���\Vm�:�z�0�j������t����U�`��1
���x��ا��>����]������d����]����c��������Z ��ג�\*��g�ip��?R�������Q[�����2�\ͼ)\�݈��7mS>�E�RF)s�)t%���ӷn=SNtC4�&{p��^:�����������7�v5'����^p���S���� �C�1p`IKm���� ,��X��>�#D�����3�2̡E�'s���e���i���lP��/�a���<L����C�/��Bk�Z3!�Pmtɋ@*Ym�!��-UWIĔ��Q]��^��z�.��5~�9�m?0Iz�����7�u�@Q���@ ����� _E��m\#]1�Bf�!���(�Ԍ	AªF����B��F��7lG'�����3�Ks��ڂ�f�%�ſm�Q��T͹�၏;�VM�A�8��鐗��/	C]nhп�G;�� ��D�
��k��y�k�
P�'�]�������w51�y=�Fa�$�ۗ�Uh&��L���o��I�v��������aT�n�{�v{�m��Փ�v�q₄�!q�$$�+BB+��{�U�n{<o�̓Ce�]��U���U��*0�g��$RT����|�h���僛�v�	&�@�DX/k�)&��A�J[��MU	�Z�ABW�ˮ�}��q$����O58�xB�}���n"��4��t��E�~���23F��x\�&�Op]��r�Yn�Ѕƾ�L4o�3\��C�ʰ}̂tO����m���Į��}��^�??�������ޕLܻ�%���e;�6�71��2��>k���NP��2?''�9Fm�苃{�k���=Ài���}A���K0�NS�=i�)D�RCB�sM�(|t�L�jl�"$H��J�\���?��i�����j�����j�������D�D0j�\�.C<����D7�����my��A�'kLG�S�vmc
��b�����M������q�'�;�с���������'.;����OQ��R�i�&Ӯ��G�����'k*X6�f��oIt�!�T|8��H Шt��	��
�X�
)V���t�&sT:PՉ�"�N�]��5\6�萩���\[����w]�L���F��f�H����Fb?$~�Je�u��˜�?�_y�MϟC
w�ܟ:5M|��}�we ��P�[I���g&y
�1�e�a�h�a��=�7w����D���*#��I��D����T<Il���Q���^ɇ��%����[�����?>���	�o����?��M��ɿ�C����� ~u���_�}k�/0V�m�#�I�ɟ}��9*)�^\V�d$�K�X������^L��r�����N$�9	3$����R7���'=y�j?Y���g�~f��������|������H��#���x{��5C�A��l݆~�0�{W8��=����7�ׯ���A����[X��#��!��2� c5�(U��ts�ҋ���0Ϛ6��G����g�j���g����"�<| Xu��d����*�+0�b;�M�턴��#��
g��pVKg �NZ�O#��0�.�Bk��~,
u�朦�=fۭ��3�,����m;G�gΦD؄�Z�Ұ<�F�3�>�s6&8��lw^��-ʖ��i;����m�UL�ܼ|�n$��`��Ԡ]i3lz00���Qq���y?\
�\'a��y{lQK����X7uŢs�b�U/�$����ʳunϔ|�����>(��\�fQ5�*]+����
t�ƊP>��L��m��ĢCܴi�>[�c�:��9^��y`��)�SQ����98�b����Ɵ�R{4�����M�"[�,�4�f����<��6�T�"晴�X�k�fr����YS���Qi�f����m&�`�j4�:����XJ���5��cE�ZOH���jy�������t�%qW�%qW�%qW�%qW�%qW�%qW�%qW�%qW�%qW�%qW�%�sy�b0�o6
t4���H|��4X�v�}���ND��aΖT�\�D�zv���v��'ng5�BK�ϗ�=wq=J
�[���۹��]���p�ND*�����9�����t��S�il�DK����T�%6�g}��L�Ȓ5��I��Ή����\�;u[�3Փ	5ƶz�Z�z�Cx��E�O�cн�,��G �ir���5�x�賥MuS2��c�ڹ}��)хY<S��)��$jO�	�b2M�΍�-5�-1����,O��R��˅AT��c-��4+�n��#=��^v8K'��Z����ڋ��o};�K;���vBo���ym�m�����9��`7�����,��q��a���E�|8?���]�>���Ў�w�Qإ��l�.���}˯S(���f��k~.���#T[���G��~���
��7w�����A�w�~�����ZSVZBS&������"�SeZ�2���$�^�������9�nx>?�����s��	���r����<=�E�&jZ.�1]5�S]�e[��D`��� ��P��DZdԮ�,xf�8��$�ӬF��,�\!5Mf��}v\Urg5"���[�#93�ʕa��څ}m�v��~7Ig���5�yۚwⴙ'�\Q��q�ؠ�6q"��ʤ���n�=�����͡�4KW�� #�Ș�B��Uk�e��-�C�U�n������T�y�Z���m�F�E����>"��Z.�,����(�A�$/Qb�9SQ9I�'A������A��0Q���#f��Q�>3R�q]���F�V�����7�����~�Z�ɢ@Y��Z����&LK%.]���__^�������{��� ��� ��r�󏄯UL�������3nQf��n�4�Ic�4���+y�N�V�=u'p�F�����/7�Z�����'�S�e1�<�-Sk��Lz�T���8-w��h�Pʥ����՚c����8��K�ձ��N�����_�Gi-{6w�t��>/�����Z�m'P�@9+д}�(���ټA���\Hj���\a>S��t?���9��U�(�<��l�(\p�Ȱ^��� �GݓtU�w��b�5��+6R�"��z�=��+��u*�ʊ�t������Rt�;Z�����A1BE�b��0��e����u�N�E�H+G"�g��xt����aJrĄQ�-��֑v�v�<�ŏ:q�%!ocgB�v	�s&�*�ҙ 8�I��C!�s��J�8�՚�ݣ�x�L�*GTGzk�e&\>2sY��Y����(�����L�]'�D��z�i��1}���4"��O�G��C!<��š����x�gj磥�n��Z�������w�	1 q� nX^ߡ0�~Ik�J�5i>��q����If^�gC"�G
e4���њa�؍y;2C���ܪ-#.������t[�F��+�U�䇥�U��8��wq黡w��[0���<S�6o�Ǐ�?"�a����F�wCooDM�n���n�ZWLk�9/�B;>����|��95��X	�z�x�4t�'�#~��ЖJ�a����/������/I�{+i=�8�!H�	���AOn4��|F�ǠW&�@�d������r��x� ̾6Ri]5 Q�B{�5�~[���y��n�~�9�`���������n�в<QLS1C��.�
�MǇz]:yiҹAO�R�!^s���s��-��!<�5���y�I�.���F�~��*>���E�������M�$��z
>wr��rgb���
>6_&�����I���1+`�c0C��:'Bz�]U��Q�/�]�ݙ������6�f_]�榯��;�9$?s����\#�ѥ�yI,��VK=���k��,_�^dyM�~�.��g����-�8�R�O8 j�hOo-X���t�^��A$�(r�������N�� 䣃D�"�����3u�6 D�!FW�݃���P����A|��H.�Sӻ���$���-��S]&G
�Y�Q���Ӱ��SG^���l A=_��0�ʀ%LH8ӽ�-*�1鎟`uQ���v.�o�~�:^�@Šޙ�c\D��Y�����,2]��I1 ��Qϳ>Hd���öb��\2V�m�{����6v|f�Crm�P��k��@���`�`�Љ=�SS.|��{������:�F]m�C�n@��-�ĪSU��ew"�r����k?V6�������ݛ7o(wL4���	�v�aa?>Z�tޮ�M�G�z���ί8�$�4�Y�*�����ӑk���@�N���Өk���h]��B��]��o^b���)�2�ָ9�C܊�`�éI��$�?��eE�R^m��׸8s��@�����0>���fL0�u�aK�nɚ(:F�����6N��r�����M&�ʁ��*���
�R����(cC=��lƀ9 �Zt�Ø޽��;u�pJ@$N��|;x�e�n��x�t�J���!Byb��Q=mt������\( %��	.��Qs�;Z%Aq�Ț����*��07�x�^1�<�<
����7����6�� َ��6�g����]n9,�����з�b������K�X����	���ୃ&�ze�6K^UqU����s��%�gҤ�kW���زQ����׏��d�Mб�t���Jp��%b$:�Pi�֘�U�ɶ���ؕ@T�<r%r���0P231�=�
뚉�5�!%���Xeu��7���;Dxh���ۡP=6���0�T4�n�9�3�Lte)�����ȫ���/:�B��1��;��4��������8�1�H�lc2p��z��ҍ���W�
@�q�w�!��l��Wg�z�U�?/��w�N�k˸f�"M���G���_���J>�ǱB|�� �кNT����V��orW��xV�s4S糧Y�]��,�X��V~�ܒ��Տ�:�V�!�-�%>�*zu��K7(|5m]���8{0V�)�k�X9 �A/�HJQ �D*U@"���d���*=JN�( �R����RO�e� O+ �����d��v��+V�{Vp�{�K���.��f}���|
SPS�!7nŖ���(�cIe��L I�"�t$%��*�nd  �d<��"�dZ�IFwH��d:��S
�@��!�J�@����&�ʟbi�`�6T�:���7m���-f��F�m�n�lͿ����z��z[��\�<W��t�Tɗ�c��LV��z9��2Ͳu��x��U�Rj�o�o�X����b�5����[��d�����%�Q��g����]W�04��j^YA,�Ǉs�S�τ��V��6'ݰ�Y������Z�Z-��&���q��v���q�k����["��R7%K߾D�}�_��r���x�>[�sh���r���q�����g4_�V���,�4����)Wf��,>����a8F[��30	O�#7�:0��D���!y�R��S�KĉW�6��V�G0k����r�ϟ�9�U�	�u�<=:��]/tMw�5ɋD0��^���E�A��e�	��y"-r�_�i�npϲ�6T���>[if,����	ȻL�ٻ�洵f��_qߩ{�<ܪ����@1��&�<I ��_�vCbǎ�v�^)!&hKk��ݽ��D��>�_�[�줗W����]�&�3��i��g��~�.#Ǯs�~�T�����{���+��kz�|�f���?[�7~����>�\���ۣx/��߯g�w�m_��񖸰���q�~|������;K~��ޅw�HS�u;��g<�w�G�E|I�{�o�>||������\��W��I�����	�_P��������W��7��$M2��(������߲��Ӱ�(���7G��������g�4��26� (�������H�����������?�����O������'�G3����H �3`?�3��~��G�������������_I�9
ŤH�1����Rd�.�#?��
c^$�2��+��K���Gݝ�8��O��?������c2y�g>*&�l�\���!J��hS��^FIy�b��4nz{���W�fyÏ:z�.��^��t3�{��9�}ѝL����P㟆�p�6�N}8�&��v<��=������,��<�~<���ڝ?8����/���!EO�}�X����I��(�����?�������E�O������&��	�?
���2��/���?���O	����H��_;q/�@�%B�������o���G����#�_�ET����O��o���$�9�0��t��%�����S�	�H���}����[�a���M��?"`���Z p��9���� �G�����ǋ/��Z=h�E�-e�T��t���m�穐���TVO���K�'����k�Y3���yi�$�����Շ���������I�l�⇊&�fi�85�Ge57�r�������p�6�Sf�W[��y�ɕV��wj�Y@�O���w�M����?���/�}>�}���Y���FH��Fg��+o�͂��\>^���6�cs������þO������4S����q��9w*M�.�-%kVM�P��]���<t9���7��ե(���m�ٶa��N�#S�N�oK`�����0`�����(�n�����a����%
5�����?Q0�	��	����	�������?�
`���I��E��ϭ�����{�{���Q +���&�?8��P�_^������k��=��}>��O7�|���U�/>�������!��s��;���z���v�殅�>��������dd���0�����%�L�7���/�F)g��b$9��$M\nj}~Ķ��6X��S]vx�2�������l��5��zTS���CH?UT;7V�w����9�k���/���Xn��v��#����>��e����p<3��V��*W�J:�Dnu��R�U��x^1Փz%#'idH���U��-������ �G���?�@���c���1�� ��ϭ�p��ٽp����$����Q@	ሣ��䩈��9��� &c6!�0dx�煐f��dB>��	Ș������?��h�;���S�kLe�.W�O��T�oO�a�����kӊ9�$AU}���E1r�{�3��x��<Io�Gu���u����v68��}�\�KFҭ�%i�O4�m���1^E���pI5�-;Ïj���Z����gq(x���p�[(p��!�+X�?�����s�9��E_�O����;㿝e��]C/��DHb�uF���xw����r�yӐs�t�{���&÷��������)_��V��3����$TՃǒ���$)c�W��sJ�y��F�R��/r>O�v��e������A��Z��Ӑ�-����O���� 꿠��8@��A��A��_��ЀE �'7��,	A�!�K��;��_���o'lVUe?�-B�Q�D?o���i!��'9z���,;)qV[���  �/�c 񭞽;�,U�joN�J��xq�l�G+��6�r�����i��g��ێ�v�RV��hV�S��:U�ҥ����Bc �QI଺h[��K�Y��۩de��4�H<����'�_���w���e��V��T���VI�r��<}����˵r��c���)Z R�l[��ӂHQ�-�i��6RSM:l{l*%��T�����/5������B��m��{��ݭ+e1��O�R5e2�4��$V�h���t�j�eK��Y��G���y�X�5��m̾�'Ţ���[olF2ލ8�?����X�(����C��@��/������C�
���4y����� 	����@������	$��( ��������_�������$?�9?�I!�#��ِ�%��y��b�y1f� �L����D)f���y?�������_N��$����^+��N��冋�ץ	nн��4+g�֦Ǟx�dW6?��:-��}t�;5WK�ꑻMMܗ��\0Jk=Y��A�����Z�=��]v�x����j���R��U%֫t�-�YT�����a���;� ��������%�G@��o���4�������?��!����<�q�?���O�7�?��C��/_~�/cT����� �?x���r��_뿭]kٳJǨ�T���0Y鳹}S��
���d���[��1����k�{j�/G��Ok��o�;�����'ՊG�X�]݉��bS���隽Us/X�ɰџr���~�[Wj����w4�r��G�d�'x�\-G0R3jwx�Տ�$oL�]�i�l����j^�%�+ʹ����w�b(��4gyc�Y/�84�VkK�ޜ�u�����*;�M�U[eӆ���l��0fE�$q}�<^z%A3��Y�ݼ'�ը���5��ª�Ue��}��MI�9Ġg��>99��$�#���X�e#���`�oA@��`�;����s�?������Z��?����;��<�H ��P���P�����>N�e�R X��ϭ�p�8�/����#dp���_����������=����M��C����w���=��b���3�#�O��m�� �� *��_��B� ��/��a�wQ(����` ����ԝ���H���9D� ��/���;�_��	��0�@T�����? �?���?��%������B�"`���3�@@�������� �#F�m! ������H ��� ��� ����
�`Q  ����������9j`���`��	�����������?�D�_:I���(@������po|��0�	��(�G���/P���P��G��������(�(������4[mc� ���[����̳{�?�N�OQg1���#2D�G��B6C�����8^�|2<�D�S��K%���,'��~����gx
����M����s�?}��Wk�S�Y�T�ܿ�l;!I#o6��jR�&��'���#j[��|��W�8<u��ލ;���rg�WS۵:kӝ�*�*�N=v��W� N�7s�v�;r�y̹�]�$긿tW�]�EǴ�e���Z�KƋX1�+S���|��/8f�a����P�����ԷP��C�W����)�����s���8�?���w��1�C)ku�Ji�XY�9��ڴ�:��P�Cv��������,sv��:��V�Ko�c#��w�=�I�ڭ}#�ԡbl��p��N�4�Uy�ޘZ����r��L��i��=�9�����f�;���?��	����C������/����/����+6��`������?迏�K��u���~�J}�cԾ����N�{QI��_��*�����"�4�S�*�f�u ��?f�t��u7,���L��S����Q,i��?1jiv�ƞ�6�>OvR��;Ic�O��)�6#&��㤙�k��vZ]�J��*'n�]?y�����ҩ��ۭ(�����������I��,Т}�VN�vlU�=ED�m�rZ$�(֠�8��b�Fz�,ʦn�FM8�F��񑦂� `&bdd~y�#���9��T�6g^C�(Fg1�Rj�+����<+E�L��um���݆��G�5'l���������6��Ϸ�����_�(���?)�p�����|�r����)X4�!���;�������_ݠ�[�X�_���H����i��=�e��Q �?�z��~@��?��������C�^��Y]U���W���/��r0v&%)�h�3��	\h������Γ��J??,]�Շ��v�UOg�s�s?�j~M�o����#����\O�|��y��7��)uٹ�./�ˋk	�mI�+w�$|̴�׬��(���Ω/��u]J���։6ט���ի�l���<���޳#��S�����,9C��)Y�����z�*3?����O���AWn=ъ�T�5����s��e͕d�_~�5����#�o�_�keS�����EU�9�n��bo��܏�N�����/�l�4��C�m��Ϛ��,sb�dM��B��GT���svp�Q\���^W�C[�/vNs1�rJ��(��+�s�;��2�DzzYc�Ǯ�}�ii����������n������?!�Ȁ�?F"�Ҿ4bB�?���4"Y����(XF���!�q Q~L�T�����������?$������䚗��$�$�{�v����뇀os�(�Ǟ?���ʕo�
��rQ+P��Z|��I��������!����A�Qs�� �����a��b������@�!�K���������Lܷ��Di+��������E����cA��s���%�F�-�7�R�G�'�wI����L�}�����~Oi?�uy?��dN�VNT�&�x���{Wڬ(�e��+�z/^�//�������<�L*���V�o�^3o�VeVV^�ҽ"2��p�u�>g�u�u�g��>R�{���\�\��u1Y�7ʎ��N��i�w5C})������<sE�rd_���~ȷ��]���;�~�&�]�cQ�aǦT�'e��Ti�ce�x����֞��|}f���q?֙�uo&i�����Fƌ!׳n�X����]�ci&gmkݍ������6�6�1ʋ�ך�+�Du����If���?�wE�q/��3A�?��:�t��c�J錟N'�(�0LM�T\��U,٣'�`Y�)B%p*قWk�{Cd�����ʳ�迷�����K��)�q썐cM��f�H� ��]]`�G�������˖T� �*[`��k���j������_(��K�ޭ��@�e�,�5���	��������C������� +�����&�gp��3������A���c���<v��}�%T[���ۃ[����?�ۜ|�h}��xf'�u�nǾ�( &�8rV	�v}~ꬄS��>u6�d�|�V��-����u�
�֩����t劝�\^[�km�������B^�<���y��Bg*����nz�1��Ѿ3Y���74:-���:��oL��N"ܠeD�x�.j8E����c��ï��������i�/�m��e�G��#�fٸy��Yq|?���5u�mjk�{�l����ژ�23�wM��ۺ��x'O,^R�7V]�䄃�l�mu��g՞!-&�Ҙ�G�/(C� \ŔcW�-�B�8�X���#�*5$s�7Y`XS�Nq$k6�V0#F|��V��l��Q���[��2A���B�_T@�������?�,�A��B������ߙ �?!��?!���A��U��\C ���������0��2�0�+
����%�a�?����������;迷��/��}���C�����I��lP�gn����3#d��7i��#���������_��y�:.���������������2B������?w�'����g���?�B䄬����?$[ �#���?������3��� O�E!��������ʍ��d�"�?T��B��7�	���C& �� �����Y�?����?��+���n(��/DN(D�����?��g� �� ��|����?��O&�S�����9���������e�b�?���B����� ���!��qQ���0����k�F����??@������_�o�X�!#��u��qӪ̒R�I0�R3k�Aꦺ4+U�0����$���VS�=i`5���M����ã�_�o��������@�$aQ�)̯��`-�msm�;��a��%K<��:���j:6��[4}v�ܯ`u�4��H vh���M���u���ĊX���6���=��!��2��2�WCta��.�O�H�7�
�Pz�*�pCi�i�g�BD�'-����w>kUy�$7�������1޻����`(B����!��?���oP����P������'�_>�)	�n��E����=�?N�ڄ�=b��8��f9��F0�;���wyf���5^㿦0Yw���h�jz�`;�u��ȥpt�$�N�JU<��L�Q��]�/���)����J�z�XK����P=�<�_�b����	y�����?b���P��/���P��_P��_0��/��Ѐ9����o�_����������_�cE���V��#	ܐ�~8�'ο���x�uN��kk�3�->lC^�����r��`ڧ0���io7�۩�M�]͛��*G��O�;&��%r.o�Z"ɶ���51u@��u�WԾ��W��1�QBs�չ]�%/���~�"����g-7���
8K��^.S���7���>k�ѥ�@�� �7���:�Wj�גy���D�#�8{>w�]��x_�����*խ�qt����[Gny�W#�Gd�z*�a��}1}gخ�I�;!5i�鸫K��mUv���5�kA���?具��_�d��"���K��M�G�I�?!���Q�g��1��Y 3�y���������7�؍��
�?���iX��� ��ϝ��;�?0��	r��W������������������H�.��#+��s��	����������qQ������	r��d������_!�����X�1"��o�1���_��8�����9�����z������^��M��:ʶ�C���K�GL=�~��ȷ����k?�C�J�GZ��|E��͍����k��ux����~ŉ��>w����yZ)���!��H���CsYs�N��dm�(;.�[8M[�Y��=��8:.H6�����ˑ}e���"�Z�{-�E�����pv�E-��R���&R�펕��>�[{�����m"��~Ygf�ֽ���#{�3�\Ϻ<��0JC����:�L��ֺ�uGm�3lrc��5�W
��r{3D������0(�����ܐ��{�x�m�����_!���sC����%�d�B��w��0������_���_���$�������E��n�������
����
��w����F!����_����4�������n�;bG�'U'J��g�j�_����K�ux�s���Fw'�k���  /|��X;���5U�nV庪�4�U����۲:��Jc*C#D9:l�x���ÁݮLl���c�B��?�W5kM�߯@�"��R��E T0��x��ִ�)�5�g�����ji�)�r�LB�l�a��uXM��2G�5�#�J#2p�b��[�����tY3gx�k��Ç�ߌB�?���/���	r�ϻ%�?��+�W�;����,P�'k$���4iUWkU�XV0�0)L�I�� �j͠p��T3MJ74�6jU�X����~�?2���������l�=��1f�^Uk�>sF&v�_M�p�ts-�V���y*��3m�����V�?���Zo6���������v��B��Q^��=%r��p^N�"�	��t �zت�`�ϯE��������"Py7����?�����?�!w�Y0	�n��D����=�?��L함�$�C�RGפ:]qo�iEb���Q���������?Q��hG��_'���GnP>�[�)���i(L�V�0Z���S�;�+��W��+i:�1� �m��r�MhΎI@���(F���E�����G������9��_P����꿠��`��_��?��A�EU@��/�i��,���kٺOO�C�D�2��F��ݤt����K����V�\x]P^[�^�t�S�~�w���q��6{U�׶hLj<�O5d�V�բ�D'�΂��V�J�66ϔ�j�~�h��(wv]n����S���:�Sٸ��y����x�q�q���1�Pb�c������Ƚ����Qk���UɋƚRd^C�X��V�p�Ҕ��sX�(�78>���<J~4��L������ˍ�V�"�q G��	ku;PFǗt��Hg��V�B����Z�:���Ʋ�=�Z�S�h굨e�|z�B��fca���99�+�������mm���Y>Eǯ볿����O�� �
��.ݹex����Qz�ҹ���ig�tR݄Q��6�J"�d�=/J�{���Ͻi��ӽ��l�����^���|L脥w�}��#n��ץ���w�e������3��y��z*>0���8:�>�~٘�bK��r�t�������k���)���=O���>��8E��tZ�������j��jjh#�?J�щJ[�d:A�� ��.���E%u�I�W���Q�qH�#�V�l����H�\:��G������/?�����,��%;<�5�׿r��~�x��������T��?K~�L^%gE���kr��~��#�2!��y�l(�3oB?=���nJ�m�}�{�~��2��XM������7������ty$JѶ���$�9��&�ߚ��K���W��<ǳJ��������{��)�G�`�~$���x��o� �$o�jF�?�����Ͽ�;�7$����{�������z���='�`�%�0�iX��@�y����~9Żm�NL�_Fa	�~N�is�F�����C��~��ӋU���{������x��.�%?1�;��a�=��ݎ(K���E�E�0%�����Rz�O_�0��r�i���KW�����Ч���g    P,�?�6�m � 